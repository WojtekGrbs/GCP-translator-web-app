# Assumptions:
# 1. IAM service account is created for the project
# 2. Docker images are in Artifact Registry of the project and have their URL


variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
  default     = "eu-west1"
}

variable "cloudsql_region" {
  description = "The GCP region for Cloud SQL"
  type        = string
  default     = "europe-west1"
}

variable "iam_service_account_email" {
  description = "The service account email for the IAM service"
  type        = string
  # Can set to default if locally
}
variable "api_gateway_region" {
  description = "The GCP region for Cloud SQL"
  type        = string
  default     = "europe-west1"
}

variable "translation_quota_limit" {
  description  = "Maximum translation service invokes per user"
  type = number
  default = 12
}

variable "vpc_region" {
  description = "The GCP region for VPC"
  type        = string
  default     = "europe-west1"
}
variable "firestore_name" {
  description = "firestore identifier"
  type        = string
  sensitive   = true
  default     = "translations"
}

variable "bucket_region" {
  description = "The GCP region for Google Buckets"
  type        = string
  default     = "EUROPE-WEST1"
}

variable "profanity_filter_image" {
  description = "Container image for the profanity filter service"
  type        = string
# Can set to default if locally
}

variable "translator_image" {
  description = "Container image for the translator service"
  type        = string
# Can set to default if locally
}

variable "postgresql_table_log_name" {
  description = "Table name for logging data"
  type        = string
  default     = "TRANSLATION_LOGS"
}


variable "db_connection_string" {
  description = "Database connection string for Cloud SQL"
  type        = string
  default     = "test"
}

variable "db_password" {
  description = "Password for the Cloud SQL user"
  type        = string
  sensitive   = true
  default     = "test"
}
