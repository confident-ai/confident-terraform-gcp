output "cluster_name" {
  value = module.gke.cluster_name
}

output "configure_kubectl" {
  description = "Command to point kubectl at the cluster."
  value       = "gcloud container clusters get-credentials ${module.gke.cluster_name} --region ${var.confident_gcp_region} --project ${var.confident_gcp_project_id}"
}

output "database_url" {
  description = "PostgreSQL connection string (Helm secrets.data.DATABASE_URL)."
  value       = module.storage.database_url
  sensitive   = true
}

output "test_cases_bucket" {
  value = module.storage.test_cases_bucket
}

output "payloads_bucket" {
  value = module.storage.payloads_bucket
}

output "clickhouse_backup_bucket" {
  value = module.storage.clickhouse_backup_bucket
}

output "app_service_account_email" {
  description = "Set as Helm serviceAccount.annotations[\"iam.gke.io/gcp-service-account\"]."
  value       = module.storage.app_service_account_email
}

output "eso_service_account_email" {
  description = "GSA for the external-secrets-sa KSA (null unless secret manager created)."
  value       = module.storage.eso_service_account_email
}

output "code_executor_function_url" {
  description = "Helm codeExecutor.gcp.functionUrl / CODE_EXECUTOR_GCP_FUNCTION_URL (null when disabled)."
  value       = local.create_function ? module.function[0].service_url : null
}

output "secret_manager_secret_id" {
  description = "Helm externalSecrets.remoteKey (null unless confident_create_secret_manager=true)."
  value       = module.storage.secret_manager_secret_id
}

output "redis_url" {
  description = "Managed Redis URL (Helm redis.externalUrl; null unless confident_managed_redis_enabled=true)."
  value       = module.storage.redis_url
}

output "helm_values" {
  description = "Ready-to-paste Helm values (DATABASE_URL comes from the sensitive database_url output)."
  value       = module.storage.helm_values
}
