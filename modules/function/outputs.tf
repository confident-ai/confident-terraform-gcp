output "function_name" {
  description = "Helm codeExecutor.gcp.functionName."
  value       = google_cloudfunctions2_function.this.name
}

output "function_uri" {
  value = google_cloudfunctions2_function.this.url
}
