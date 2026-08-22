# Cloud Functions

Creates a Google Cloud Functions v2 function and the source bucket/object it
uses.

## Resources

Source storage bucket, source object reference, and Cloud Functions v2 function.

## Requirements

Terraform >= 1.5 and the Google provider declared in `versions.tf`.

## Usage

```hcl
module "function" {
  source       = "./modules/gcp/gcp_cloudfunctions"
  project_id   = var.project_id
  function_name = "example-function"
  source_bucket_name = "example-source-bucket"
  source_object = "function.zip"
}
```

## Inputs

Project, region, function/runtime/entry point, source bucket/object, memory,
and timeout.

## Outputs

`function_id`, `function_name`, and `service_uri`.
