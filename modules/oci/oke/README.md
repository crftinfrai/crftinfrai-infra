# OKE cluster

Creates an OCI Kubernetes Engine cluster and node pool with module-owned or
existing network inputs.

## Resources

VCN, internet gateway, route table, node/load-balancer subnets, OKE cluster,
and node pool.

## Requirements

Terraform >= 1.5 and the OCI provider declared in `versions.tf`.

## Usage

```hcl
module "oke" {
  source             = "./modules/oci/oke"
  compartment_ocid   = var.compartment_ocid
  availability_domain = var.availability_domain
  tenancy_ocid       = var.tenancy_ocid
  user_ocid          = var.user_ocid
  fingerprint        = var.fingerprint
  private_key_path   = var.private_key_path
  region             = "ap-hyderabad-1"
  cluster_name       = "example-oke"
  node_image_ocid    = var.node_image_ocid
}
```

## Inputs

OCI authentication, compartment/AD/region, network mode and CIDRs, cluster
name/version/API access, node shape/count, and image OCID.

## Outputs

`cluster_id`, `k8s_version`, `node_pool_id`, `node_subnet_id`, and
`lb_subnet_id`.
