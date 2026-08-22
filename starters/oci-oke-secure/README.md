# OCI Secure OKE Starter

Creates a private OCI VCN/subnet, private-endpoint OKE cluster, and node pool.
It is a network and cluster foundation; it does not deploy workloads or an
ingress controller.

## Resources

The current `main.tf` creates a VCN, private subnet, OKE cluster, and node
pool. Node shape, OCPUs, and memory are configurable.

## Prerequisites

- Terraform and OCI provider access
- An OCI compartment OCID and permissions for networking and OKE
- OCI CLI configuration through `oci setup config` or an approved profile

## Configuration

Supply required `compartment_ocid`. Important inputs include `region`, CIDRs,
`oke_name`, node shape, OCPU count, and memory. The default name is a generic
example.

## Deploy

```bash
terraform init
terraform plan
terraform apply
```

OKE nodes and networking can incur charges.

## Destroy

```bash
terraform destroy
```

Review node-pool and cluster removal before confirming.
