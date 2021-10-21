resource "google_storage_bucket" "gae-helloworld" {
  name          = "${local.project_id}-${var.bucket_name}"
  location      = "US"
  force_destroy = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = var.bucket_retention
    }
    action {
      type = "Delete"
    }
  }
}
