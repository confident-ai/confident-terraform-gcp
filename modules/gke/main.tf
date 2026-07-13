locals {
  name            = "${var.confident_application_name}-${var.confident_environment}"
  node_pool_name  = "${var.confident_region_prefix}il${var.confident_application_code}${var.confident_environment_code}001"
  node_sa_account = "${var.confident_application_code}-${var.confident_environment_code}-gke-node-sa"
}

resource "google_service_account" "node" {
  account_id   = local.node_sa_account
  display_name = "Confident AI GKE node service account"
  project      = var.confident_gcp_project_id
}

resource "google_project_iam_member" "node" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/artifactregistry.reader",
  ])
  project = var.confident_gcp_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.node.email}"
}

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version = "~> 36.0"

  project_id         = var.confident_gcp_project_id
  name               = "${local.name}-gke"
  regional           = true
  region             = var.confident_gcp_region
  zones              = var.confident_availability_zones
  kubernetes_version = var.confident_kubernetes_version

  network           = var.confident_network_name
  subnetwork        = var.confident_subnetwork_name
  ip_range_pods     = var.confident_ip_range_pods
  ip_range_services = var.confident_ip_range_services

  enable_private_endpoint = !var.confident_public_gke
  enable_private_nodes    = true
  master_ipv4_cidr_block  = var.confident_master_ipv4_cidr_block

  master_authorized_networks = var.confident_public_gke ? [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "all"
    }
  ] : []

  horizontal_pod_autoscaling = true
  http_load_balancing        = true
  gce_pd_csi_driver          = true

  # Workload Identity — the GCP equivalent of pod identity (no OIDC provider).
  identity_namespace = "${var.confident_gcp_project_id}.svc.id.goog"
  release_channel    = "STABLE"

  create_service_account   = false
  service_account          = google_service_account.node.email
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  node_pools = [
    {
      name               = local.node_pool_name
      machine_type       = var.confident_node_machine_type
      image_type         = var.confident_node_image_type
      min_count          = var.confident_node_group_min_size
      max_count          = var.confident_node_group_max_size
      initial_node_count = var.confident_node_group_desired_size
      disk_size_gb       = 100
      disk_type          = "pd-ssd"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = google_service_account.node.email
      enable_secure_boot = true
    }
  ]

  node_pools_labels = {
    all = {
      environment = var.confident_environment
      project     = var.confident_application_name
    }
  }
}

resource "google_project_iam_member" "admin_user" {
  count   = trimspace(var.confident_gke_admin_user) != "" ? 1 : 0
  project = var.confident_gcp_project_id
  role    = "roles/container.admin"
  member  = "user:${var.confident_gke_admin_user}"
}
