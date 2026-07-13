# Minimal Confident AI deployment on GCP.
#
# Prerequisites: an existing VPC network + subnet with two secondary ranges
# (pods + services) and Cloud NAT. See ../DEPLOY.md to create one, or use your own.
# After `terraform apply`, install the confident-ai Helm chart using the outputs.

terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = "my-gcp-project"
  region  = "us-central1"
}

module "confident_ai" {
  source  = "confident-ai/confident-ai/google"
  version = "~> 0.1"
  # For local testing before publishing, use a relative path instead:
  # source = "../"

  # --- required: project + your existing network ---
  confident_gcp_project_id    = "my-gcp-project"
  confident_gcp_region        = "us-central1"
  confident_network_name      = "confident-prod-vpc"
  confident_network_id        = "projects/my-gcp-project/global/networks/confident-prod-vpc"
  confident_subnetwork_name   = "confident-prod-subnet"
  confident_ip_range_pods     = "confident-pods"
  confident_ip_range_services = "confident-services"

  # --- prod naming convention ---
  confident_environment      = "prod"
  confident_environment_code = "p"

  # let you reach the cluster from your machine (false = private-only)
  confident_public_gke = true

  # turn on once you have the sandbox image in Artifact Registry
  confident_code_executor_enabled = false
}

output "configure_kubectl" {
  description = "Run this to point kubectl at the new cluster."
  value       = module.confident_ai.configure_kubectl
}

output "database_url" {
  description = "-> Helm secrets.data.DATABASE_URL"
  value       = module.confident_ai.database_url
  sensitive   = true
}

output "app_service_account_email" {
  description = "-> Helm serviceAccount.annotations[\"iam.gke.io/gcp-service-account\"]"
  value       = module.confident_ai.app_service_account_email
}
