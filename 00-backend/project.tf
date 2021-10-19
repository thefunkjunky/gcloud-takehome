data "google_billing_account" "helloworld" {
  display_name = var.billing_account
  open         = true
}

resource "google_project" "helloworld" {
  name       = "Hello World Project"
  project_id = var.project_id
  org_id = var.org_id
  billing_account = data.google_billing_account.helloworld.id

}
