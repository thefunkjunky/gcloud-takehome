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
    bucket = "idme-take-home-tfstate"
    prefix = "backend/helloworld/terraform.tfstate"
  }
}


data "terraform_remote_state" "common" {
  backend = "gcs"
  config = {
    bucket  = "${var.project_id}-tfstate"
    prefix  = "backend/terraform.tfstate"
  }
}

provider "google" {
  # credentials = file(var.credentials)
  project = var.project_id
  region  = var.region
}
