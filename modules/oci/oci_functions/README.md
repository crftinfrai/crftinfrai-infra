# OCI Functions

Creates an OCI Functions application and function from a container image.

## Resources

Functions application and function in the supplied compartment/subnet.

## Requirements

Terraform >= 1.5 and the OCI provider declared in `versions.tf`.

## Usage

```hcl
module "function" {
  source          = "./modules/oci/oci_functions"
  tenancy_ocid    = var.tenancy_ocid
  user_ocid       = var.user_ocid
  fingerprint     = var.fingerprint
  private_key_path = var.private_key_path
  region          = var.region
  compartment_ocid = var.compartment_ocid
  application_name = "example-functions"
  function_name    = "example-function"
  image            = "iad.ocir.io/example/hello:latest"
  subnet_id        = var.subnet_id
}
```

## Inputs

OCI authentication, region/compartment, application/function names, image,
memory, timeout, and subnet ID.

## Outputs

`application_id` and `function_id`.
