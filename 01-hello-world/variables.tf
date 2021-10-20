locals {
  project_id = data.terraform_remote_state.common.outputs.project.project_id
  project_num = data.terraform_remote_state.common.outputs.project.number
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

