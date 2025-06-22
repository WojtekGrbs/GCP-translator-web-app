resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = "projects/${var.project_id}/global/networks/default"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  depends_on = [google_project_service.enable_service_networking]
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "google-managed-services-default"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "projects/${var.project_id}/global/networks/default"
}

resource "google_vpc_access_connector" "connector" {
  name          = "cloud-run-connector"
  region        = var.cloudsql_region
  network       = "default"
  ip_cidr_range = "10.8.0.0/28"
  depends_on    = [google_project_service.enable_vpc_access]
}
