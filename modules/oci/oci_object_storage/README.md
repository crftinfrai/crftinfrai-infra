# OCI Object Storage

Creates an OCI Object Storage bucket.

## Resources

One `oci_objectstorage_bucket` in the supplied namespace and compartment.

## Requirements

Terraform >= 1.5 and the OCI provider declared in `versions.tf`.

## Usage

```hcl
module "bucket" {
  source         = "./modules/oci/oci_object_storage"
  tenancy_ocid   = var.tenancy_ocid
  user_ocid      = var.user_ocid
  fingerprint    = var.fingerprint
  private_key_path = var.private_key_path
  region         = var.region
  compartment_id = var.compartment_id
  namespace      = var.namespace
  bucket_name    = "example-bucket"
}
```

## Inputs

OCI authentication, region, compartment, namespace, bucket name, and access
or storage-class settings.

## Outputs

`bucket_id` and `bucket_name`.
