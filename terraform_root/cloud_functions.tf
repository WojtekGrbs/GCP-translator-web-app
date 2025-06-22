resource "google_storage_bucket" "functions_bucket" {
  name          = "${var.project_id}-functions-bucket"
  location      = var.bucket_region
  force_destroy = true
}

resource "google_storage_bucket_object" "orchestrator_zip" {
  name   = "functions-${filemd5("./functions.zip")}.zip"
  bucket = google_storage_bucket.functions_bucket.name
  source = "./functions.zip" # Adjust this path accordingly.
}

resource "google_storage_bucket_object" "firestore_export_zip" {
  name   = "firestore_export-${filemd5("./firestore_export.zip")}.zip"
  bucket = google_storage_bucket.functions_bucket.name
  source = "firestore_export.zip"
}

resource "google_cloudfunctions_function" "orchestrator" {
  name                  = "translation-orchestrator"
  description           = "Orchestrates translation requests"
  runtime               = "python311"
  region                = var.cloudsql_region
  entry_point           = "handler"
  source_archive_bucket = google_storage_bucket.functions_bucket.name
  source_archive_object = google_storage_bucket_object.orchestrator_zip.name
  trigger_http          = true
  available_memory_mb   = 256

  service_account_email         = google_service_account.orchestrator.email
  vpc_connector                 = google_vpc_access_connector.connector.id
  vpc_connector_egress_settings = "ALL_TRAFFIC"

  environment_variables = {
    # These URLs are obtained from Cloud Run service status.
    GOOGLE_FUNCTION_SOURCE = "main.py"
    PROJECT_ID             = var.project_id
    PROFANITY_SERVICE_URL  = google_cloud_run_service.profanity_filter.status[0].url
    TRANSLATOR_SERVICE_URL = google_cloud_run_service.translator.status[0].url
    
    # Not necessary as of the latest architecture
    DB_NAME                = google_sql_database.translator_db.name
    DB_HOST                = google_sql_database_instance.postgres_instance.connection_name
    DB_USER                = google_sql_user.default.name
    DB_PASSWORD            = var.db_password

    REDIS_HOST = google_redis_instance.quota_redis.host
    REDIS_PORT = google_redis_instance.quota_redis.port
    REDIS_QUOTA = var.translation_quota_limit

    DEPLOYMENT_VERSION = filemd5("./functions.zip")

  }
  depends_on = [
    google_vpc_access_connector.connector,
    google_sql_database_instance.postgres_instance,
    google_project_service.enable_vpc_access,
    google_storage_bucket.functions_bucket,
  ]
}

resource "google_cloudfunctions_function" "export_firestore" {
  name        = "exportFirestoreToPostgres"
  description = "Exports all Firestore data to Cloud SQL and deletes it"
  runtime     = "python311"
  entry_point = "export"
  region      = var.cloudsql_region
  timeout     = 300 
  source_archive_bucket = google_storage_bucket.functions_bucket.name
  source_archive_object = google_storage_bucket_object.firestore_export_zip.name

  trigger_http        = true
  available_memory_mb = 512

  service_account_email  = google_service_account.firebase_export.email

  environment_variables = {
    DB_NAME                = google_sql_database.translator_db.name
    DB_HOST                = google_sql_database_instance.postgres_instance.connection_name #google_sql_database_instance.postgres_instance.private_ip_address
    DB_USER                = google_sql_user.default.name
    DB_PASSWORD            = var.db_password
    TABLE_NAME             = var.postgresql_table_log_name
    DEPLOYMENT_VERSION     = filemd5("./firestore_export.zip")
  }

  vpc_connector                 = google_vpc_access_connector.connector.id
  vpc_connector_egress_settings = "PRIVATE_RANGES_ONLY"
}