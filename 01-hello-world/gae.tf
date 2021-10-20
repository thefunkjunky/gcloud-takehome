locals {
  object_name = "gae-helloworld-${var.version_id}.zip"
}

data "archive_file" "gae_zip" {
  type        = "zip"
  output_path = local.object_name

  source_dir = "app/"
}

resource "google_storage_bucket_object" "helloworld_zip" {
  name   = local.object_name
  source = local.object_name
  bucket = google_storage_bucket.gae-helloworld.name
}

resource "google_app_engine_application" "helloworld" {
  project     = local.project_id
  location_id = var.region
  database_type = "CLOUD_FIRESTORE"
}

resource "google_project_service" "compute" {
  project = local.project_id
  service = "compute.googleapis.com"

  disable_dependent_services = false
}
resource "google_project_service" "debugger" {
  project = local.project_id
  service = "clouddebugger.googleapis.com"

  disable_dependent_services = false
}
resource "google_project_service" "appengine_api" {
  project = local.project_id
  service = "appengine.googleapis.com"

  disable_dependent_services = true
}

resource "google_project_service" "cloud_resource_manager" {
  project = local.project_id
  service = "cloudresourcemanager.googleapis.com"

  disable_dependent_services = true
}

resource "google_project_service" "appengine_flex" {
  project = local.project_id
  service = "appengineflex.googleapis.com"

  disable_dependent_services = false
}

resource "google_project_service" "datastore" {
  project = local.project_id
  service = "datastore.googleapis.com"

  disable_dependent_services = false
}

resource "google_project_service" "storage" {
  project = local.project_id
  service = "storage.googleapis.com"

  disable_dependent_services = false
}

resource "google_project_iam_member" "gae_api" {
  project = local.project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:service-${local.project_num}@gae-api-prod.google.com.iam.gserviceaccount.com"
}

resource "google_app_engine_standard_app_version" "notflex" {
    delete_service_on_destroy = false
    inbound_services          = []
    instance_class            = "F1"
    # noop_on_destroy           = false
    project                   = local.project_id
    runtime                   = "python39"
    service                   = var.service
    version_id                = "v2"

    entrypoint {
    shell = "gunicorn -b :$PORT main:app"
  }

    deployment {
      zip {
        source_url = "https://storage.googleapis.com/${google_storage_bucket.gae-helloworld.name}/${google_storage_bucket_object.helloworld_zip.name}"
      }
  }

    # handlers {
    #     auth_fail_action = "AUTH_FAIL_ACTION_REDIRECT"
    #     login            = "LOGIN_OPTIONAL"
    #     security_level   = "SECURE_OPTIONAL"
    #     url_regex        = "/static/(.*)"

    #     static_files {
    #         application_readable  = false
    #         expiration            = "0s"
    #         http_headers          = {}
    #         path                  = "static/\\1"
    #         require_matching_file = false
    #         upload_path_regex     = "static/.*"
    #     }
    # }
    # handlers {
    #     auth_fail_action = "AUTH_FAIL_ACTION_REDIRECT"
    #     login            = "LOGIN_OPTIONAL"
    #     security_level   = "SECURE_OPTIONAL"
    #     url_regex        = "/.*"

    #     script {
    #         script_path = "auto"
    #     }
    # }
    # handlers {
    #     auth_fail_action = "AUTH_FAIL_ACTION_REDIRECT"
    #     login            = "LOGIN_OPTIONAL"
    #     security_level   = "SECURE_OPTIONAL"
    #     url_regex        = ".*"

    #     script {
    #         script_path = "auto"
    #     }
    # }

    # timeouts {}
}

# resource "google_app_engine_flexible_app_version" "helloworld-flexible-default" {
#   project    = local.project_id
#   service    = "default"
#   version_id = "v1"
#   runtime    = var.runtime

#   # entrypoint {
#   #   shell = "gunicorn -b :$PORT main:app"
#   # }

#   deployment {
#     zip {
#       source_url = "https://storage.googleapis.com/${google_storage_bucket.gae-helloworld.name}/${google_storage_bucket_object.helloworld_zip.name}"
#     }
#     cloud_build_options {
#       app_yaml_path = "app.yaml"
#     }
#   }

#   liveness_check {
#     path = "/"
#   }

#   readiness_check {
#     path = "/"
#   }

#   automatic_scaling {
#     cool_down_period = "120s"
#     cpu_utilization {
#       target_utilization = 0.5
#     }
#   }

#   delete_service_on_destroy = false
# }

# resource "google_app_engine_flexible_app_version" "helloworld-flexible-notdefault" {
#   project    = local.project_id
#   service    = var.service
#   version_id = "v1"
#   runtime    = var.runtime

#   # entrypoint {
#   #   shell = "gunicorn -b :$PORT main:app"
#   # }

#   deployment {
#     zip {
#       source_url = "https://storage.googleapis.com/${google_storage_bucket.gae-helloworld.name}/${google_storage_bucket_object.helloworld_zip.name}"
#     }
#     cloud_build_options {
#       app_yaml_path = "app.yaml"
#     }
#   }

#   liveness_check {
#     path = "/"
#   }

#   readiness_check {
#     path = "/"
#   }

#   automatic_scaling {
#     cool_down_period = "120s"
#     cpu_utilization {
#       target_utilization = 0.5
#     }
#   }

#   delete_service_on_destroy = true
# }
