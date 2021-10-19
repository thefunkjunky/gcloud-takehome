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
    bucket = "idme-takehome-tfstate"
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

variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

variable "bucket_name" {
  description = "bucket_name"
}
variable "bucket_retention" {
  description = "bucket_retention"
}
variable "runtime" {
  description = "runtime"
}
variable "version_id" {
  description = "version id"
}
variable "service" {
  description = "service name"
}
variable "credentials" {
  description = "credentials file"
}

provider "google" {
  credentials = file(var.credentials)
  project = var.project_id
  region  = var.region
}
