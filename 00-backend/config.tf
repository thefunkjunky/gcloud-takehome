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
    prefix = "backend/terraform.tfstate"
  }
}

variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

variable "org_id" {
  description = "org_id"
}

variable "billing_account" {
  description = "billing_account"
}

provider "google" {
  project = var.project_id
  region  = var.region
}
