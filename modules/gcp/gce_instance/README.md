# Compute Engine instance

Creates a Compute Engine VM with optional network, firewall, NAT, static IP,
service account, and DNS resources.

## Resources

VPC/subnet or existing network references, firewall rules, Cloud Router/NAT,
service account, VM, optional address, and optional Cloud DNS records.

## Requirements

Terraform >= 1.5 and the Google provider declared in `versions.tf`.

## Usage

```hcl
module "vm" {
  source     = "./modules/gcp/gce_instance"
  project_id = var.project_id
  region     = "us-central1"
  zone       = "us-central1-a"
  instance_name = "example-vm"
}
```

## Inputs

Project/region/zone, network mode, CIDRs or existing IDs, machine/image,
firewall toggles, startup data, and DNS options.

## Outputs

See `outputs.tf` for VM, address, network, and internal-CIDR outputs.
