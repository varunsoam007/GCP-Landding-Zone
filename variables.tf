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
