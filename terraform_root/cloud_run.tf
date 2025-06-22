resource "google_cloud_run_service" "profanity_filter" {
  name     = "profanity-filter"
  location = var.vpc_region
  depends_on = [
    google_project_service.enable_cloud_run,
    google_vpc_access_connector.connector
  ]
  template {
    metadata {
      annotations = {
        "run.googleapis.com/ingress"              = "internal-and-cloud-load-balancing"  # Watch out, probably not needed, test with this turned off!
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.id
      }
    }
    spec {
      containers {
        image = var.profanity_filter_image
        resources {
          limits = {
            cpu    = "2"      # CHANGE TO 1
            memory = "8192Mi" # CHANGE TO 4096Mi
          }
        }
      }

      container_concurrency = 80
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service" "translator" {
  name     = "translator"
  location = var.vpc_region
  depends_on = [
    google_project_service.enable_cloud_run,
    google_vpc_access_connector.connector
  ]

  template {
    metadata {
      annotations = {
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.id
      }
    }
    spec {
      containers {
        image = var.translator_image
        resources {
          limits = {
            cpu    = "2"
            memory = "8192Mi"
          }
        }
      }

      container_concurrency = 80
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}