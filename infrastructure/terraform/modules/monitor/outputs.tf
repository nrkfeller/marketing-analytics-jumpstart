# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

output "activation_dataset_id" {
  description = "ID of the activation dataset"
  value       = google_bigquery_dataset.activation.dataset_id
}

output "vbb_activation_configuration_table_id" {
  description = "ID of the VBB activation configuration table"
  value       = google_bigquery_table.vbb_activation_configuration.table_id
}

output "monitor_logs_table_id" {
  description = "ID of the monitor logs table"
  value       = google_bigquery_table.monitor_logs.table_id
}

output "activation_metrics_table_id" {
  description = "ID of the activation metrics table"
  value       = google_bigquery_table.activation_metrics.table_id
}
