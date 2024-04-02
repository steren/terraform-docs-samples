/**
* Copyright 2024 Google LLC
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*      http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

# [START gke_enterprise]
data "google_project" "default" {
}
# [START gke_enterprise_enable]
resource "google_project_service" "anthos" {
  project = data.google_project.default.project_id
  service = "anthos.googleapis.com"
}
resource "google_project_service" "gkehub" {
  project            = data.google_project.default.project_id
  service            = "gkehub.googleapis.com"
  disable_on_destroy = false
}
# [END gke_enterprise_enable]
# [START gke_enterprise_cluster]
resource "google_container_cluster" "default" {
  name               = "gke-enterprise-cluster"
  location           = "us-central1"
  initial_node_count = 1
  # [START gke_enterprise_cluster_existing]
  fleet {
    project = data.google_project.default.project_id
  }
  # [END gke_enterprise_cluster_existing]
  # [START gke_enterprise_cluster_workload_identity]
  workload_identity_config {
    workload_pool = "${data.google_project.default.project_id}.svc.id.goog"
  }
  # [END gke_enterprise_cluster_workload_identity]
  depends_on = [google_project_service.anthos, google_project_service.gkehub]
  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = false
}
# [END gke_enterprise_cluster]
# [END gke_enterprise]
