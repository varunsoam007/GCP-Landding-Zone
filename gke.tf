# ==============================================================================
# GKE Cluster Configuration (Production-Grade Baseline)
# ==============================================================================

resource "google_container_cluster" "gke_cluster" {
  name     = "enterprise-gke-cluster"
  location = "${var.region}-a" # Zonal cluster for minimal cost. Use var.region for HA.
  project  = google_compute_shared_vpc_host_project.host.project
  
  # 1. Network Configuration
  # Placing the cluster inside the Hub VPC and Private Subnet.
  network    = google_compute_network.hub_vpc.id
  subnetwork = google_compute_subnetwork.private_subnet.id
  
  # VPC-Native is the modern standard for GKE. It assigns actual VPC IP addresses to Pods.
  # This relies on the secondary_ip_range defined in our private_subnet in network.tf.
  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pod-range"
    services_secondary_range_name = "gke-svc-range"
  }

  # Note: The cluster endpoint is public by default. Nodes will have private IPs
  # and reach the internet via the Cloud NAT configured in network.tf.

  # 2. Workload Identity (Critical for Security)
  # Allows Kubernetes service accounts to impersonate GCP IAM service accounts securely
  # without downloading service account JSON keys. Highly recommended for production.
  workload_identity_config {
    workload_pool = "${var.host_project_id}.svc.id.goog"
  }

  # 3. Upgrade Strategy
  # Use Release Channels so Google automatically manages master upgrades.
  # "REGULAR" provides a good balance between stability and fresh features.
  # This ensures Terraform doesn't fight with background GKE upgrades.
  release_channel {
    channel = "REGULAR"
  }

  # 4. Node Pool Management
  # Best practice: Delete the default node pool and create custom ones.
  # This allows modifying node machine types later without destroying the whole cluster.
  remove_default_node_pool = true
  initial_node_count       = 1

  # Wait for GKE API to be enabled before creation
  depends_on = [
    google_project_service.container_api
  ]
}

# ==============================================================================
# Custom Node Pool Configuration
# ==============================================================================
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = "${var.region}-a"
  cluster    = google_container_cluster.gke_cluster.name
  project    = google_compute_shared_vpc_host_project.host.project

  initial_node_count = 1

  # 1. Scaling Configuration
  # We use cluster autoscaler to save costs and scale up only when pods need more space.
  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }
  
  # 2. Node Configuration
  node_config {
    machine_type = "e2-standard-4" # Minimum recommended for GitOps/ArgoCD workloads
    disk_size_gb = 50
    disk_type    = "pd-standard"

    # Enables Workload Identity on the nodes
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Oauth scopes required for nodes to pull images, write logs, etc.
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  # 3. Node Management (Required for smooth Terraform operations)
  # Let GKE auto-repair unhealthy nodes and auto-upgrade them to match master.
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # 4. Terraform Lifecycle Rule (CRITICAL FOR AUTOSCALING)
  # When autoscaling is enabled, GKE changes the node count behind the scenes.
  # If we don't ignore this, `terraform apply` will forcefully scale the cluster 
  # back down to initial_node_count, disrupting workloads.
  lifecycle {
    ignore_changes = [
      initial_node_count,
      node_count
    ]
  }
}
