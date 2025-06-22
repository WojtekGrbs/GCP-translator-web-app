terraform {
  required_version = ">= 0.14"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
}

data "google_project" "current" {
  project_id = var.project_id
}