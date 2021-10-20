locals {
  apis = [
    "compute.googleapis.com",
    "clouddebugger.googleapis.com",
    "appengine.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "appengineflex.googleapis.com",
    "datastore.googleapis.com",
    "storage.googleapis.com"
  ]
}

resource "google_project_service" "appengine_flex" {
  for_each = toset(local.apis)
  project = local.project_id
  service = each.value

  disable_dependent_services = false
}
