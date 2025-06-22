resource "google_service_account" "orchestrator" {
  account_id   = "orchestrator-fn-sa"
  display_name = "Orchestrator Function Service Account"
}

resource "google_service_account" "firebase_export" {
  account_id   = "firebase-export-fn-sa"
  display_name = "Firebase Export Function Service Account"
}

resource "google_project_iam_member" "orchestrator_can_sign" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.orchestrator.email}"
}
resource "google_cloud_run_service_iam_member" "profanity_filter_invoker" {
  service  = google_cloud_run_service.profanity_filter.name
  location = var.vpc_region
  role     = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.orchestrator.email}" # allUsers (wtedy dziala 100%)
}

resource "google_cloud_run_service_iam_member" "translator_invoker" {
  service  = google_cloud_run_service.translator.name
  location = var.vpc_region
  role     = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.orchestrator.email}" # allUsers (wtedy dziala 100%)
}

resource "google_cloudfunctions_function_iam_member" "allow_gateway_invocation" {
  project        = var.project_id
  region         = var.cloudsql_region
  cloud_function = google_cloudfunctions_function.orchestrator.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${var.iam_service_account_email}"
}

resource "google_project_iam_member" "firestore_access" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_cloudfunctions_function.orchestrator.service_account_email}"
}

resource "google_project_iam_member" "firestore_access_exporter" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.firebase_export.email}"
}

resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.firebase_export.email}"
}