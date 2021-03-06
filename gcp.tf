provider "google-beta" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

resource "google_compute_network" "cloudflare-gke-network" {
  provider                = google-beta
  name                    = "${var.resource_prefix}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "cloudflare-gke-subnetwork" {
  provider = google-beta

  name    = "${var.resource_prefix}-subnetwork"
  region  = var.gcp_region
  network = google_compute_network.cloudflare-gke-network.self_link

  ip_cidr_range = "10.110.0.0/20"
  secondary_ip_range = [
    {
      range_name    = "${var.resource_prefix}-pod"
      ip_cidr_range = "10.112.0.0/20"
    },
    {
      range_name    = "${var.resource_prefix}-service"
      ip_cidr_range = "10.114.0.0/20"
    }
  ]
}

resource "google_container_cluster" "cloudflare-gke-cluster" {
  provider = google-beta

  name                     = "${var.resource_prefix}-cluster"
  initial_node_count       = 1
  remove_default_node_pool = true

  network    = google_compute_network.cloudflare-gke-network.self_link
  subnetwork = google_compute_subnetwork.cloudflare-gke-subnetwork.self_link

  release_channel {
    channel = "REGULAR"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.resource_prefix}-pod"
    services_secondary_range_name = "${var.resource_prefix}-service"
  }
}



resource "google_container_node_pool" "cloudflare-gke-node_pool" {
  provider           = google-beta
  name               = "${var.resource_prefix}-node-pool"
  cluster            = google_container_cluster.cloudflare-gke-cluster.name
  initial_node_count = var.initial_node_count
  autoscaling {
    max_node_count = var.max_node_count
    min_node_count = 0
  }
  node_config {
    disk_size_gb = 10
    machine_type = var.machine_type
    preemptible  = true
  }
}
