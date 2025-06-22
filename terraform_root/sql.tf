resource "google_sql_database_instance" "postgres_instance" {
  name             = "translator-sql-instance"
  database_version = "POSTGRES_12"
  region           = var.cloudsql_region

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled = false
      private_network = "projects/${var.project_id}/global/networks/default"
    }
  }
}

resource "google_firestore_database" "default" {
  project     = var.project_id
  name        = "(default)"              # the compulsory ID for the first DB
  location_id = var.cloudsql_region      # pick ANY Firestore region/multi-region
  type        = "FIRESTORE_NATIVE"       # or DATASTORE_MODE if you need it

  # optional but recommended: protects against accidental deletion
  delete_protection_state = "DELETE_PROTECTION_ENABLED"

  depends_on = [google_project_service.enable_firestore]
}


resource "google_sql_database" "translator_db" {
  name     = "translatordb"
  instance = google_sql_database_instance.postgres_instance.name
}

resource "google_sql_user" "default" {
  depends_on = [google_sql_database_instance.postgres_instance]

  name     = "translator_user"
  instance = google_sql_database_instance.postgres_instance.name
  password = var.db_password
}