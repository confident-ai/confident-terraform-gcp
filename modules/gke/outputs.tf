output "cluster_name" {
  value = module.gke.name
}

output "cluster_endpoint" {
  value     = module.gke.endpoint
  sensitive = true
}

output "identity_namespace" {
  description = "Workload Identity pool the app KSA binds through."
  value       = "${var.confident_gcp_project_id}.svc.id.goog"
}
