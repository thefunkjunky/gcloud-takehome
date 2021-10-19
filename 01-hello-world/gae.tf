locals {
  object_name = "gae-helloworld-${var.version_id}.zip"
}

data "archive_file" "gae_zip" {
  type        = "zip"
  output_path = local.object_name

  source_dir = "app/"
}

resource "google_storage_bucket_object" "helloworld" {
  name   = local.object_name
  source = local.object_name
  bucket = google_storage_bucket.gae-helloworld.name
}

resource "google_app_engine_application" "helloworld" {
  project     = var.project_id
  location_id = var.region
  database_type = "CLOUD_FIRESTORE"
}


resource "google_app_engine_standard_app_version" "helloworld" {
    delete_service_on_destroy = false
    inbound_services          = []
    instance_class            = "F1"
    noop_on_destroy           = false
    project                   = "idme-takehome"
    runtime                   = "python39"
    service                   = "default"
    version_id                = "20211018t192415"

    deployment {
      zip {
        source_url = "https://storage.googleapis.com/${google_storage_bucket.gae-helloworld.name}/${google_storage_bucket_object.helloworld.name}"
      }
  }

    handlers {
        auth_fail_action = "AUTH_FAIL_ACTION_REDIRECT"
        login            = "LOGIN_OPTIONAL"
        security_level   = "SECURE_OPTIONAL"
        url_regex        = "/static/(.*)"

        static_files {
            application_readable  = false
            expiration            = "0s"
            http_headers          = {}
            path                  = "static/\\1"
            require_matching_file = false
            upload_path_regex     = "static/.*"
        }
    }
    handlers {
        auth_fail_action = "AUTH_FAIL_ACTION_REDIRECT"
        login            = "LOGIN_OPTIONAL"
        security_level   = "SECURE_OPTIONAL"
        url_regex        = "/.*"

        script {
            script_path = "auto"
        }
    }
    handlers {
        auth_fail_action = "AUTH_FAIL_ACTION_REDIRECT"
        login            = "LOGIN_OPTIONAL"
        security_level   = "SECURE_OPTIONAL"
        url_regex        = ".*"

        script {
            script_path = "auto"
        }
    }

    timeouts {}
}



