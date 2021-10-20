resource "google_storage_bucket" "tfstate" {
  name          = "${var.project_id}-tfstate"
  location      = "US"
  force_destroy = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 14
    }
    action {
      type = "Delete"
    }
  }
}
