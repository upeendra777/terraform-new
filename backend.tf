terraform {
  backend "gcs" {
    bucket = "afroz-terraform"  # GCS bucket name
    prefix = "terraform/state"              # Path within the bucket (e.g., a folder structure)
  }
}
