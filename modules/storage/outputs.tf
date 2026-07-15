output "database_url" {
  description = "PostgreSQL connection string (Helm secrets.data.DATABASE_URL)."
  value       = "postgresql://${google_sql_user.this.name}:${urlencode(local.postgres_password)}@${google_sql_database_instance.this.private_ip_address}:5432/${google_sql_database.this.name}"
  sensitive   = true
}

output "test_cases_bucket" {
  value = google_storage_bucket.this["test_cases"].name
}

output "payloads_bucket" {
  value = google_storage_bucket.this["payloads"].name
}

output "clickhouse_backup_bucket" {
  value = try(google_storage_bucket.this["clickhouse_backup"].name, null)
}

output "app_service_account_email" {
  description = "Set as Helm serviceAccount.annotations[\"iam.gke.io/gcp-service-account\"]."
  value       = google_service_account.app.email
}

output "eso_service_account_email" {
  description = "GSA for ESO (annotate the external-secrets-sa KSA with this). Null unless created."
  value       = try(google_service_account.eso[0].email, null)
}

output "redis_url" {
  description = "Managed Redis URL (Helm redis.externalUrl; set redis.internal=false). Null unless enabled."
  value       = try("redis://${google_redis_instance.this[0].host}:${google_redis_instance.this[0].port}", null)
}

output "secret_manager_secret_id" {
  description = "Helm externalSecrets.remoteKey (null unless created)."
  value       = try(google_secret_manager_secret.app[0].secret_id, null)
}

output "helm_values" {
  description = "Ready-to-paste Helm values (DATABASE_URL comes from the sensitive database_url output)."
  value       = <<-EOT
    serviceAccount:
      create: true
      name: ${var.confident_service_account_name}
      annotations:
        iam.gke.io/gcp-service-account: ${google_service_account.app.email}
    config:
      cloudProvider: GCP
    storage:
      testCasesBucket: ${google_storage_bucket.this["test_cases"].name}
      payloadsBucket: ${google_storage_bucket.this["payloads"].name}
      gcp:
        projectId: ${var.confident_gcp_project_id}
        region: ${var.confident_gcp_region}
  EOT
}
