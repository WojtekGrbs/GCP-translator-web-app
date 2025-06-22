resource "google_redis_instance" "quota_redis" {
  name               = "quota-checker-redis"
  project            = var.project_id
  region             = var.cloudsql_region
  tier               = "BASIC"
  memory_size_gb     = 1
  authorized_network = "projects/${var.project_id}/global/networks/default"

  depends_on = [
    google_project_service.enable_redis,
    google_service_networking_connection.private_vpc_connection,
  ]
}