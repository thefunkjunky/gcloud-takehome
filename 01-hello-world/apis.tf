locals {
  apis = [
    "clouddebugger.googleapis.com",
    "appengine.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "datastore.googleapis.com",
    "storage.googleapis.com"
  ]
}

resource "google_project_service" "apis" {
  for_each = toset(local.apis)
  project = local.project_id
  service = each.value

  disable_dependent_services = true
}
