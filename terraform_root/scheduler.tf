# Create a service account for the scheduler
resource "google_service_account" "scheduler_invoker" {
  account_id   = "scheduler-invoker"
  display_name = "Cloud Scheduler Cloud Function Invoker"
}

# Grant the service account permission to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.export_firestore.project
  region         = google_cloudfunctions_function.export_firestore.region
  cloud_function = google_cloudfunctions_function.export_firestore.name
  
  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_service_account.scheduler_invoker.email}"
}
# Cloud Scheduler Job
resource "google_cloud_scheduler_job" "daily_job" {
  name        = "firestore-export-daily"
  description = "Triggers Firestore export to Postgres daily"
  schedule    = "0 0 * * *" # every day at midnight
  time_zone   = "Etc/UTC"
  region      = var.vpc_region
  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions_function.export_firestore.https_trigger_url
    headers = {
      "Content-Type" = "application/json"
    }
    
    # Add these for authentication
    oidc_token {
      service_account_email = google_service_account.scheduler_invoker.email
      audience              = google_cloudfunctions_function.export_firestore.https_trigger_url
    }
  }
}