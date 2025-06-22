import functions_framework
import os
import time
import logging
from functools import partial
from tenacity import retry, stop_after_attempt, wait_exponential

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

from flask import Request
from google.cloud import firestore
from google.cloud.sql.connector import Connector
import sqlalchemy

# ------------ Configuration ------------
PROJECT_ID = os.getenv("PROJECT_ID")
INSTANCE = os.getenv("DB_HOST")  # format: project:region:instance
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
TABLE_NAME = os.getenv("TABLE_NAME", "translation_logs")
BATCH_DELETE_SIZE = 400

print("DB_HOST:", os.getenv("DB_HOST"))


# Initialize Connector (will be reused if warm)
connector = None

# ------------ Database Connection Helpers ------------
@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=4, max=10))
def get_connection():
    """Return a pg8000 connection handled by Cloud SQL Connector."""
    global connector
    if connector is None:
        connector = Connector()
    
    start = time.time()
    try:
        conn = connector.connect(
            instance_connection_string=INSTANCE,
            driver="pg8000",
            user=DB_USER,
            password=DB_PASSWORD,
            db=DB_NAME,
            ip_type="PRIVATE",
            port="5432",
            timeout=30,  # Increased timeout
        )
        logger.info(f"SQL connection established in {time.time() - start:.1f}s")
        return conn
    except Exception as e:
        logger.error(f"SQL connection failed after {time.time() - start:.1f}s: {str(e)}")
        raise

def init_engine():
    """Initialize SQLAlchemy engine with retry logic."""
    return sqlalchemy.create_engine(
        "postgresql+pg8000://",
        creator=get_connection,
        pool_size=5,
        pool_timeout=30,
        pool_recycle=1800,
    )

# ------------ Main Function ------------
@functions_framework.http
def export(request: Request):
    if request.headers.get("X-CloudScheduler") != "true":
        return ("Bad Caller", 403)

    logger.info("Translation log export started")
    
    try:
        # Initialize engine inside the function for better cold start handling
        # Initialize Firestore client
        firestore_db = firestore.Client()
        print("Firestore connection working:", firestore_db._target)
        engine = init_engine()
        logger.info("Database engine initialized")
        
        inserted_rows = 0
        processed_docs = 0
        batch = firestore_db.batch()

        with engine.begin() as conn:
            logger.info("Engine working...")
            firestore_db = firestore.Client()
            logger.info("Engine working...")

            docs_iter = firestore_db.collection_group("logs").stream()
            logger.info("Parsing collection stream...")
            
            for doc in docs_iter:
                data = doc.to_dict()
                params = {
                    "doc_id": doc.id,
                    "uid": data.get("uid"),
                    "original_text": data.get("original_text"),
                    "translated_text": data.get("translated_text"),
                    "language_code": data.get("language_code"),
                    "quota_remaining": data.get("quota_remaining"),
                    "toxic_probability": data.get("toxic_probability"),
                    "is_toxic": data.get("is_toxic"),
                    "created_at": data.get("created_at"),
                }

                try:
                    conn.execute(INSERT_STMT, params)
                    inserted_rows += 1
                    batch.delete(doc.reference)
                    processed_docs += 1

                    if processed_docs % BATCH_DELETE_SIZE == 0:
                        batch.commit()
                        batch = firestore_db.batch()
                        logger.info(f"Committed {processed_docs} deletions")

                except Exception as exc:
                    logger.error(f"Failed to process doc {doc.id}: {exc}")

            # Commit any remaining deletes
            if processed_docs % BATCH_DELETE_SIZE:
                batch.commit()
        logger.info(f"Job complete - {inserted_rows} rows inserted, {processed_docs} docs deleted")
        return ("Success", 200)

    except Exception as e:
        logger.error(f"Export failed: {str(e)}")
        return ("Internal Server Error", 500)

    finally:
        if connector:
            try:
                connector.close()
            except:
                pass

# SQL Statement (moved after function definition)
INSERT_STMT = sqlalchemy.text(
    f"""
    INSERT INTO {TABLE_NAME} (
        doc_id, uid, original_text, translated_text, language_code,
        quota_remaining, toxic_probability, is_toxic, created_at
    ) VALUES (
        :doc_id, :uid, :original_text, :translated_text, :language_code,
        :quota_remaining, :toxic_probability, :is_toxic, :created_at
    ) ON CONFLICT (doc_id) DO NOTHING;
    """
) 