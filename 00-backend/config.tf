terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.88.0"
    }
  }
  required_version = "~> 1.0"
  
  backend "gcs" {
    # bucket = "${var.project_id}-tfstate"
    bucket = "idme-takehome003-tfstate"
    prefix = "backend/terraform.tfstate"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
