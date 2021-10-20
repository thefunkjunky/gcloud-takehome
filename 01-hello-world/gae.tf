
data "archive_file" "gae_zip" {
  type        = "zip"
  output_path = local.app_zip

  source_dir = "app/"
}

resource "google_storage_bucket_object" "helloworld_zip" {
  name   = local.app_zip
  source = local.app_zip
  bucket = google_storage_bucket.gae-helloworld.name
}

resource "google_app_engine_application" "helloworld" {
  project     = local.project_id
  location_id = var.region
  database_type = "CLOUD_FIRESTORE"
}

resource "google_app_engine_standard_app_version" "default" {
    delete_service_on_destroy = false
    inbound_services          = []
    instance_class            = var.instance_class
    # noop_on_destroy           = false
    project                   = local.project_id
    runtime                   = var.runtime
    service                   = "default"

    entrypoint {
    shell = "gunicorn -b :$PORT main:app"
  }
  
  env_variables = {
    PORT = "8080"
  }


  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_storage_bucket.gae-helloworld.name}/${google_storage_bucket_object.helloworld_zip.name}"
    }
  }
}

resource "google_app_engine_standard_app_version" "helloworld" {
    delete_service_on_destroy = false
    inbound_services          = []
    instance_class            = var.instance_class
    # noop_on_destroy           = false
    project                   = local.project_id
    runtime                   = var.runtime
    service                   = var.service
    version_id                = var.version_id

    entrypoint {
    shell = "gunicorn -b :$PORT main:app"
  }

    env_variables = {
      PORT = "8080"
    }

  depends_on = [
    google_app_engine_standard_app_version.default
  ]

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_storage_bucket.gae-helloworld.name}/${google_storage_bucket_object.helloworld_zip.name}"
    }
  }
}
