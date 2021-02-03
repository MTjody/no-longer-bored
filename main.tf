terraform {
  required_version = ">= 0.14"
  # backend "gcs" {

  # }
}

locals {
  credentials_file = file(var.keyfile_path)
}

provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = local.credentials_file
}

variable "project_id" {
  type    = string
  default = "bored-dev"
}

variable "keyfile_path" {
  type    = string
  default = "./.keyfiles/credentials.json"
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "bored_service_account" {
  type    = string
  default = "bored-app@bored-dev.iam.gserviceaccount.com"
}

variable "bucket_name" {
  type    = string
  default = "bored-dev-bucket"
}

variable "bucket_archive_filepath" {
  type    = string
  default = "bored.zip"
}

resource "google_storage_bucket" "bucket" {
  name = var.bucket_name
}

data "archive_file" "http_trigger" {
  type        = "zip"
  output_path = format("%s/%s", path.root, var.bucket_archive_filepath)
  source {
    content  = file("./functions/bored-proxy/index.js")
    filename = "index.js"
  }
}

resource "google_storage_bucket_object" "archive" {
  name                = format("%s#%s", var.bucket_archive_filepath, data.archive_file.http_trigger.output_md5)
  bucket              = google_storage_bucket.bucket.name
  source              = data.archive_file.http_trigger.output_path
  content_disposition = "attachment"
  content_encoding    = "gzip"
  content_type        = "application/zip"
}

resource "google_cloudfunctions_function" "function" {
  name        = "bored-api-proxy"
  description = "A proxy function for GET requests to the Bored Api"
  runtime     = "nodejs14"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = "boredProxy"

  service_account_email = var.bored_service_account

  project = var.project_id
  region  = var.region
}

# IAM entry for all users to invoke the function
# https://stackoverflow.com/a/62525239/7469853
resource "google_cloudfunctions_function_iam_binding" "binding" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role = "roles/cloudfunctions.invoker"
  members = [
    "allUsers",
  ]
}
