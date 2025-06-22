resource "google_api_gateway_api" "translator_api" {
  provider     = google-beta
  api_id       = "translator-api"
  display_name = "Translator API"
}

locals {
  orchestrator_function_url = google_cloudfunctions_function.orchestrator.https_trigger_url

  openapi_spec = templatefile("${path.module}/openapiswagger.yaml.tpl", {
    function_url = local.orchestrator_function_url
  })
}

resource "google_api_gateway_api_config" "translator_api_config" {
  provider      = google-beta
  api           = google_api_gateway_api.translator_api.api_id
  api_config_id = "v1"

  openapi_documents {
    document {
      path     = "openapiswagger.yaml"
      contents = base64encode(local.openapi_spec)
    }
  }
  depends_on = [google_api_gateway_api.translator_api]
}

resource "google_api_gateway_gateway" "translator_gateway" {
  provider   = google-beta
  gateway_id = "translator-gateway"
  api_config = google_api_gateway_api_config.translator_api_config.id
  region     = var.api_gateway_region
}