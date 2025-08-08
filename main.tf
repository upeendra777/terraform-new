
# 1. VPC Configuration
resource "google_compute_network" "vpc_network" {
  name                    = "vpc-network"
  auto_create_subnetworks  = false  # Disable auto-creation of subnets
}

# 2. Subnet Configuration
resource "google_compute_subnetwork" "subnet" {
  name          = "subnet-1"
  network       = google_compute_network.vpc_network.name
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"
}

# 3. Google Cloud Storage Bucket
resource "google_storage_bucket" "terraform-afrozbucket" {
  name     = "terraform-afrozbucket"
  location = "US"
}

# 4. VM Instance Configuration
resource "google_compute_instance" "vm_instance" {
  count        = var.instance_count  # Creates multiple instances based on variable
  name         = "${var.instance_name}-${count.index + 1}"  # Unique name per instance
  machine_type = var.instance_machine_type  # Machine type from variable
  zone         = var.zone  # Zone from variable
  
  # Boot disk configuration for the VM
  boot_disk {
    initialize_params {
      image = "debian-11"
      size  = 10 # 10 GB boot disk size
    }
  }

  network_interface {
    network   = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.subnet.name
    access_config {
      # Allocate a public IP address
    }
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    echo "Hello, World!" > /var/www/html/index.html
  EOT
}

# 5. Google Kubernetes Engine (GKE) Cluster Configuration
resource "google_container_cluster" "aks_cluster" {
  name               = "my-aks-cluster"
  location           = "us-central1"

  # Cluster-wide configuration
  enable_shielded_nodes = true
  logging_service      = "logging.googleapis.com/kubernetes"
  monitoring_service   = "monitoring.googleapis.com/kubernetes"

  network    = google_compute_network.vpc_network.name
  subnetwork = google_compute_subnetwork.subnet.name

  # Use node_pool to manage node configuration
  node_pool {
    name       = "default-pool"
    node_count = 1  # Starting with 1 node for minimal setup

    autoscaling {
      min_node_count = 1
      max_node_count = 2  # Allow auto-scaling between 1 and 3 nodes
    }

    node_config {
      machine_type = var.instance_machine_type
      disk_size_gb = 30  # Disk size for each node
      disk_type    = "pd-standard"  # Standard persistent disk

      # Additional configurations
      preemptible = false  # Non-preemptible nodes
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]
    }
  }
}
