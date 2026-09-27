variable "project_id" {
  description = "The GCP Project ID"
  type        = string
  default     = "project-c487c7e3-8780-4424-9ad"
}

variable "org_id" {
  description = "The GCP Organization ID"
  type        = string
  default     = "495960749426"
}

variable "region" {
  description = "The region to deploy resources in"
  type        = string
  default     = "asia-south1"
}

variable "host_project_id" {
  description = "The Host Project ID for Shared VPC"
  type        = string
  default     = "shared-service-509706"
}

# ==============================================================================
# GKE Node Pool Configuration Variables
# ==============================================================================
variable "gke_node_machine_type" {
  description = "Machine type for the GKE primary node pool"
  type        = string
  default     = "e2-standard-4"
}

variable "gke_node_disk_size_gb" {
  description = "OS Disk size in GB for GKE nodes"
  type        = number
  default     = 50
}

variable "gke_node_disk_type" {
  description = "Disk type for GKE nodes"
  type        = string
  default     = "pd-standard"
}

variable "gke_node_min_count" {
  description = "Minimum number of nodes for autoscaling"
  type        = number
  default     = 1
}

variable "gke_node_max_count" {
  description = "Maximum number of nodes for autoscaling (capped at 3 due to 12 vCPU regional quota)"
  type        = number
  default     = 3
}
