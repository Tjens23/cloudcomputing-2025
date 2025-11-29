resource "google_project_iam_policy" "iam_policy" {
  project     = var.project
  policy_data = data.google_iam_policy.admin.policy_data
}

data "google_iam_policy" "admin" {
  binding {
    role = "roles/editor"

    members = [
      "user:mathiasydesdu@gmail.com",
      "user:hopetobylol@gmail.com",
      "user:Mathias.rojleskov@gmail.com",
      "user:Phillip713dk@gmail.com"
    ]
  }
}