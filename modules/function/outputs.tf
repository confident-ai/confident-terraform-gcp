output "service_url" {
  description = "HTTPS URL of the sandbox Cloud Run service (Helm codeExecutor.gcp.functionUrl / CODE_EXECUTOR_GCP_FUNCTION_URL)."
  value       = google_cloud_run_v2_service.this.uri
}

output "service_name" {
  value = google_cloud_run_v2_service.this.name
}
