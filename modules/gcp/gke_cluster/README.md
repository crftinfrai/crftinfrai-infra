# GKE cluster

Creates a configurable GKE cluster, node pool, and supporting VPC networking.

## Resources

Optional APIs, VPC/subnet and secondary ranges, GKE cluster, and managed node
pool; existing network resources can be selected through inputs.

## Requirements

Terraform >= 1.5 and the Google provider declared in `versions.tf`.

## Usage

```hcl
module "gke" {
  source       = "./modules/gcp/gke_cluster"
  project_id   = var.project_id
  region       = "us-central1"
  location     = "us-central1"
  cluster_name = "example-gke"
}
```

## Inputs

Project/location, network mode and names, secondary ranges, cluster security,
release channel, node sizing, labels, and existing-network inputs.

## Outputs

`cluster_name`, `endpoint`, `ca_certificate`, `location`, and `node_pool_name`.
