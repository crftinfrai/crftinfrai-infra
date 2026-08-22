# OCI Compute

Creates an OCI compute instance with optional network, public IP, and DNS.

## Resources

VCN, internet gateway, route table, subnet, security list, image lookup,
compute instance, optional reserved IP, and optional DNS records.

## Requirements

Terraform >= 1.5 and the OCI provider declared in `versions.tf`.

## Usage

```hcl
module "vm" {
  source             = "./modules/oci/oci_compute"
  compartment_ocid   = var.compartment_ocid
  availability_domain = var.availability_domain
  tenancy_ocid       = var.tenancy_ocid
  user_ocid          = var.user_ocid
  fingerprint        = var.fingerprint
  private_key_path   = var.private_key_path
  region             = "ap-hyderabad-1"
  instance_name      = "example-vm"
}
```

## Inputs

OCI authentication, compartment/AD/region, network mode and CIDRs, image,
shape, SSH users, public IP, user data, and DNS options.

## Outputs

`subnet_id`, `instance_id`, `public_ip`, and `private_ip`.
