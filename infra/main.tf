terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.6.0"
    }
  }
}

#  Establish Google as a provider
provider "google" {
  credentials = file("./secrets/terraform-demo-key.json")
  project     = var.project_id
  region      = var.project_region
  zone        = var.project_zone
}

#  Enable the API for remote resource management
resource "google_project_service" "gcp_resource_manager" {
  service = "cloudresourcemanager.googleapis.com"

  # remove on destroy
  disable_on_destroy = true
}

# Add the Cloud Run API
resource "google_project_service" "run_api" {
  service            = "run.googleapis.com"
  disable_on_destroy = true

  depends_on = [
    google_project_service.gcp_resource_manager
  ]
}

resource "google_cloud_run_service" "run_service" {
  name     = "cloud-run-demo"
  location = var.project_region

  # Provide an application to run
  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/cloud-run-demo:latest"
      }
    }
  }

  # Unique congiuration
  traffic {
    percent         = 100
    latest_revision = true
  }

  # Depends on enabling the cloud run API
  depends_on = [
    google_project_service.run_api
  ]
}

# We have to allow cloud run to be assessible to the entire web, which requires special permissions
data "google_iam_policy" "noauth" {
  # Create the noauth policy data
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

# Bind the policy to the resource
resource "google_cloud_run_service_iam_policy" "run_all_users" {
  project  = google_cloud_run_service.run_service.project
  service  = google_cloud_run_service.run_service.name
  location = google_cloud_run_service.run_service.location

  # bind the policy data
  policy_data = data.google_iam_policy.noauth.policy_data

  # don't create policy till the service is created
  depends_on = [
    google_cloud_run_service.run_service
  ]
}

# define an output to return data after building
output "service_url" {
  value = google_cloud_run_service.run_service.status[0].url
}