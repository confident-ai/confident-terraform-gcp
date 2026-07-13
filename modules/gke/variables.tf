# --- Naming ---
variable "confident_application_name" {
  type    = string
  default = "confidentai"
}

variable "confident_application_code" {
  type    = string
  default = "cai"
}

variable "confident_environment" {
  type    = string
  default = "stage"
}

variable "confident_environment_code" {
  type    = string
  default = "s"
}

variable "confident_region_prefix" {
  type    = string
  default = "dgcp"
}

# --- Project / location ---
variable "confident_gcp_project_id" {
  type = string
}

variable "confident_gcp_region" {
  type = string
}

variable "confident_availability_zones" {
  type = list(string)
}

# --- Networking (existing VPC/subnet + secondary ranges) ---
variable "confident_network_name" {
  type = string
}

variable "confident_subnetwork_name" {
  type = string
}

variable "confident_ip_range_pods" {
  description = "Name of the existing secondary range for pods."
  type        = string
}

variable "confident_ip_range_services" {
  description = "Name of the existing secondary range for services."
  type        = string
}

variable "confident_master_ipv4_cidr_block" {
  type    = string
  default = "172.16.0.0/28"
}

# --- Cluster ---
variable "confident_kubernetes_version" {
  type    = string
  default = "1.34"
}

variable "confident_public_gke" {
  type    = bool
  default = false
}

variable "confident_gke_admin_user" {
  description = "Optional user granted roles/container.admin."
  type        = string
  default     = ""
}

variable "confident_node_machine_type" {
  type    = string
  default = "n2-standard-8"
}

variable "confident_node_image_type" {
  type    = string
  default = "COS_CONTAINERD"
}

variable "confident_node_group_min_size" {
  type    = number
  default = 2
}

variable "confident_node_group_max_size" {
  type    = number
  default = 8
}

variable "confident_node_group_desired_size" {
  type    = number
  default = 4
}
