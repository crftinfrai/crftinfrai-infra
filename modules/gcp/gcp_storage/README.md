# Cloud Storage

Creates a Google Cloud Storage bucket.

## Resources

One `google_storage_bucket` with configurable location, storage class, and
uniform bucket-level access.

## Requirements

Terraform >= 1.5 and the Google provider declared in `versions.tf`.

## Usage

```hcl
module "bucket" {
  source      = "./modules/gcp/gcp_storage"
  project_id  = var.project_id
  bucket_name = "example-unique-bucket"
}
```

## Inputs

`project_id`, `bucket_name`, `location`, `storage_class`, and access settings.

## Outputs

`bucket_name` and `bucket_url`.
