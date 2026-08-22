# GCP Secure GKE Starter

Creates a custom VPC and subnet with secondary ranges, private GKE with
Workload Identity, private Cloud SQL PostgreSQL, and a reserved global IP for
future ingress. The current configuration does not create an ingress
controller or application workload.

## Resources

The current `main.tf` creates the VPC, private service connection, GKE cluster
and managed node pool, Cloud SQL instance/database/user, and reserved IP.

## Prerequisites

- Terraform and Google provider access
- A billing-enabled Google Cloud project
- `gcloud auth application-default login` and permissions for networking,
  GKE, Cloud SQL, and service networking

## Configuration

Supply required `project_id`. Important optional inputs include `region`,
`zone`, `network_name`, `cluster_name`, private-node settings, database tier,
database credentials, and labels. The default names are generic examples.

## Deploy

```bash
gcloud auth application-default login
terraform init
terraform plan
terraform apply
```

GKE, Cloud SQL, and reserved networking can incur charges.

## Destroy

```bash
terraform destroy
```

Cloud SQL deletion protection and data retention should be reviewed before
destruction.
