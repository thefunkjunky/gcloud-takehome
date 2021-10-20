resource "google_storage_bucket" "gae-helloworld" {
  name          = "${var.project_id}-${var.bucket_name}"
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

resource "google_storage_bucket_access_control" "gae-helloworld" {
  bucket = google_storage_bucket.gae-helloworld.name
  role   = "WRITER"
  entity = "allUsers"
}
