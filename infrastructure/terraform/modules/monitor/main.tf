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

locals {
  app_prefix = "monitor"
}

module "project_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "14.1.0"
  
  disable_dependent_services  = false
  disable_services_on_destroy = false
  project_id = var.project_id
  
  activate_apis = [
    "bigquery.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ]
}

resource "google_bigquery_dataset" "activation" {
  dataset_id                  = "activation"
  friendly_name               = "Activation Dataset"
  description                 = "Dataset for activation monitoring and configuration"
  location                    = var.location
  default_table_expiration_ms = 3600000
  
  labels = {
    env = "production"
  }
  
  depends_on = [module.project_services]
}

resource "google_bigquery_table" "vbb_activation_configuration" {
  dataset_id = google_bigquery_dataset.activation.dataset_id
  table_id   = "vbb_activation_configuration"
  
  time_partitioning {
    type  = "DAY"
    field = "created_date"
  }
  
  labels = {
    env = "production"
  }
  
  schema = jsonencode([
    {
      name = "activation_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "activation_type"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "configuration"
      type = "JSON"
      mode = "NULLABLE"
    },
    {
      name = "status"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "created_date"
      type = "DATE"
      mode = "REQUIRED"
    },
    {
      name = "updated_timestamp"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])
  
  depends_on = [google_bigquery_dataset.activation]
}

resource "google_bigquery_table" "monitor_logs" {
  dataset_id = google_bigquery_dataset.activation.dataset_id
  table_id   = "monitor_logs"
  
  time_partitioning {
    type  = "DAY"
    field = "log_date"
  }
  
  labels = {
    env = "production"
  }
  
  schema = jsonencode([
    {
      name = "log_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "log_level"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "message"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "log_date"
      type = "DATE"
      mode = "REQUIRED"
    },
    {
      name = "timestamp"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])
  
  depends_on = [google_bigquery_dataset.activation]
}

resource "google_bigquery_table" "activation_metrics" {
  dataset_id = google_bigquery_dataset.activation.dataset_id
  table_id   = "activation_metrics"
  
  time_partitioning {
    type  = "DAY"
    field = "metric_date"
  }
  
  labels = {
    env = "production"
  }
  
  schema = jsonencode([
    {
      name = "metric_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "metric_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "metric_value"
      type = "FLOAT64"
      mode = "REQUIRED"
    },
    {
      name = "metric_date"
      type = "DATE"
      mode = "REQUIRED"
    },
    {
      name = "timestamp"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])
  
  depends_on = [google_bigquery_dataset.activation]
}

resource "google_bigquery_table" "activation_status" {
  dataset_id = google_bigquery_dataset.activation.dataset_id
  table_id   = "activation_status"
  
  time_partitioning {
    type  = "DAY"
    field = "status_date"
  }
  
  labels = {
    env = "production"
  }
  
  schema = jsonencode([
    {
      name = "activation_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "status"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "error_message"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "retry_count"
      type = "INT64"
      mode = "REQUIRED"
    },
    {
      name = "status_date"
      type = "DATE"
      mode = "REQUIRED"
    },
    {
      name = "timestamp"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])
  
  depends_on = [google_bigquery_dataset.activation]
}

resource "google_bigquery_table" "monitor_configuration" {
  dataset_id = google_bigquery_dataset.activation.dataset_id
  table_id   = "monitor_configuration"
  
  labels = {
    env = "production"
  }
  
  schema = jsonencode([
    {
      name = "config_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "config_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "config_value"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "config_type"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "is_active"
      type = "BOOLEAN"
      mode = "REQUIRED"
    },
    {
      name = "created_timestamp"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "updated_timestamp"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])
  
  depends_on = [google_bigquery_dataset.activation]
}

resource "google_bigquery_table" "activation_pipeline_status" {
  dataset_id = google_bigquery_dataset.activation.dataset_id
  table_id   = "activation_pipeline_status"
  
  time_partitioning {
    type  = "DAY"
    field = "pipeline_date"
  }
  
  labels = {
    env = "production"
  }
  
  schema = jsonencode([
    {
      name = "pipeline_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "pipeline_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "status"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "start_time"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "end_time"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    },
    {
      name = "pipeline_date"
      type = "DATE"
      mode = "REQUIRED"
    },
    {
      name = "records_processed"
      type = "INT64"
      mode = "NULLABLE"
    },
    {
      name = "error_details"
      type = "STRING"
      mode = "NULLABLE"
    }
  ])
  
  depends_on = [google_bigquery_dataset.activation]
}

resource "google_bigquery_table" "vbb_monitoring_alerts" {
  dataset_id = google_bigquery_dataset.activation.dataset_id
  table_id   = "vbb_monitoring_alerts"
  
  time_partitioning {
    type  = "DAY"
    field = "alert_date"
  }
  
  labels = {
    env = "production"
  }
  
  schema = jsonencode([
    {
      name = "alert_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "alert_type"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "severity"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "message"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "source_system"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "alert_date"
      type = "DATE"
      mode = "REQUIRED"
    },
    {
      name = "timestamp"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "resolved"
      type = "BOOLEAN"
      mode = "REQUIRED"
    },
    {
      name = "resolved_timestamp"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    }
  ])
  
  depends_on = [google_bigquery_dataset.activation]
}
