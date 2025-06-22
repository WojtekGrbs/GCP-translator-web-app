resource "google_project_service" "enable_cloud_run" {
  project = var.project_id
  service = "run.googleapis.com"
}

resource "google_project_service" "enable_cloud_functions" {
  project = var.project_id
  service = "cloudfunctions.googleapis.com"
}

resource "google_project_service" "enable_sql_admin" {
  project = var.project_id
  service = "sqladmin.googleapis.com"
}

resource "google_project_service" "enable_redis" {
  project = var.project_id
  service = "redis.googleapis.com"
}

resource "google_project_service" "enable_vpc_access" {
  project = var.project_id
  service = "vpcaccess.googleapis.com"
}

resource "google_project_service" "enable_api_gateway" {
  project = var.project_id
  service = "apigateway.googleapis.com"
}

resource "google_project_service" "enable_cloud_build" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"
}

resource "google_project_service" "enable_service_networking" {
  project            = var.project_id
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "enable_firestore" {
  project = var.project_id
  service = "firestore.googleapis.com"
}

resource "google_project_service" "enable_cloud_scheduler" {
  project = var.project_id
  service = "cloudscheduler.googleapis.com"
}