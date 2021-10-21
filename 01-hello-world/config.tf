terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.88.0"
    }
  }
  required_version = "~> 1.0"
  
  backend "gcs" {
    bucket = "idme-takehome006-tfstate"
    prefix = "backend/helloworld/terraform.tfstate"
  }
}


data "terraform_remote_state" "common" {
  backend = "gcs"
  config = {
    bucket  = "idme-takehome006-tfstate"
    prefix  = "backend/terraform.tfstate"
  }
}

provider "google" {
  project = "idme-takehome006"
  region  = var.region
}
