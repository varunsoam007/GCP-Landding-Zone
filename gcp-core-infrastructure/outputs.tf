output "vpc_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.vpc_network.id
}

output "subnet_name" {
  description = "The name of the Subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "bucket_url" {
  description = "The URL of the created bucket"
  value       = google_storage_bucket.tf_state_bucket.url
}
