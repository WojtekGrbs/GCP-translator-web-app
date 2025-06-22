output "cloud_function_url" {
  description = "HTTPS Trigger URL for the translation orchestrator Cloud Function"
  value       = google_cloudfunctions_function.orchestrator.https_trigger_url
}

output "profanity_filter_url" {
  description = "URL for the profanity filter Cloud Run service"
  value       = google_cloud_run_service.profanity_filter.status[0].url
}

output "translator_url" {
  description = "URL for the translator Cloud Run service"
  value       = google_cloud_run_service.translator.status[0].url
}

output "api_gateway_url" {
  description = "Default hostname for the API Gateway"
  value       = google_api_gateway_gateway.translator_gateway.default_hostname
}

output "openapi_spec" {
  value = local.openapi_spec
}

output "postgres_private_ip" {
  value = google_sql_database_instance.postgres_instance.first_ip_address
}