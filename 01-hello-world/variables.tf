locals {
  project_id = data.terraform_remote_state.common.outputs.project.project_id
  project_num = data.terraform_remote_state.common.outputs.project.number
  app_zip = "gae-helloworld-${var.version_id}.zip"

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

variable "instance_class" {
  description = "app engine instance_class"
}
