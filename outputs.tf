output "vpc_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.hub_vpc.id
}

output "subnet_name" {
  description = "The name of the Subnet"
  value       = google_compute_subnetwork.private_subnet.name
}

output "jksoa_ingress_ip" {
  description = "The static public IP address for jksoa.in to map in DNS"
  value       = google_compute_global_address.jksoa_ingress_ip.address
}
