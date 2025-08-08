variable "region" {
  default = "us-central1"  # Adjust to your preferred region
}

variable "zone" {
  default = "us-central1-a"  # Keep the zone variable for VM and GKE instance zones
}

variable "instance_count" {
  default = 2
}

variable "instance_name" {
  default = "my-instance"
}

variable "instance_machine_type" {
  default = "e2-medium"
}
