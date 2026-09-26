output "vpc_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.hub_vpc.id
}

output "subnet_name" {
  description = "The name of the Subnet"
  value       = google_compute_subnetwork.private_subnet.name
}

