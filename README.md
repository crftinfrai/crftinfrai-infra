# CrftInfrai Infrastructure as Code

Production-ready Terraform modules, cloud architecture templates, and starter infrastructure for AWS, Azure, GCP, and OCI — powered by CrftInfrai.

CrftInfrai helps engineers visually design cloud infrastructure, compare AWS, Azure, GCP, and OCI costs before deployment, generate Terraform, and review infrastructure before provisioning.

## Supported Clouds

- AWS
- Azure
- Google Cloud
- Oracle Cloud Infrastructure

## Current Terraform Modules

| Cloud | Modules |
|------|---------|
| AWS | EC2 instance, ECS, EKS cluster, Fargate, Lambda, RDS database, S3 bucket, VPC |
| Azure | ACI, AKS, Function App, SQL, Storage, VM |
| GCP | Compute Engine, Cloud Functions, Cloud SQL, Cloud Storage, GKE cluster |
| OCI | Autonomous Database, Compute, Database, Functions, Object Storage, OKE |

Modules are self-contained under `modules/<cloud>/<module>`. Read each module's variables and provider requirements before use.

## Architecture Templates

The versioned templates under `templates/` are complete Terraform roots:

- `aks-postgres-monitoring` — Azure AKS, PostgreSQL, and monitoring
- `aws-fargate-microservices` — AWS Fargate microservices foundation
- `azure-static-web-functions` — Azure Static Web Apps and Functions
- `cloudrun-cloudsql-postgres` — Cloud Run with private Cloud SQL PostgreSQL
- `eks-rds-argocd` — AWS EKS, RDS, and Argo CD foundation
- `gcp-serverless-webapp` — Google Cloud serverless web app
- `gke-cloudsql-argocd` — GKE, Cloud SQL, and Argo CD foundation
- `lightweight-dev-test` — small AWS EC2 development host
- `multi-cloud-failover` — AWS and GCP static-site failover-ready foundation

See each template's README for architecture, prerequisites, variables, cost considerations, and destroy instructions. `templates/index.json` is the machine-readable catalog.

## Secure Starters

- `starters/azure-aks-secure` — AKS with managed identity, RBAC, and PostgreSQL
- `starters/gcp-gke-secure` — private GKE, Workload Identity, and private Cloud SQL
- `starters/oci-oke-secure` — private OKE network and node pool foundation

## Repository Structure

```text
modules/    Reusable cloud modules
templates/  Versioned, deployable architecture roots
starters/   Secure starting architectures
examples/   Safe examples and bootstrap root
bootstrap/  Terraform state backend module
scripts/    Human-confirmed workflow helpers
docs/       Repository-level guidance
```

## Quick Start

The smallest validated root is `templates/lightweight-dev-test/v1`:

```bash
cd templates/lightweight-dev-test/v1
terraform init -backend=false
terraform validate
terraform plan
```

Provide cloud authentication through the provider's supported CLI, environment, or workload identity mechanism. Review the plan before any apply.

## Generate Infrastructure Visually

[Open the CrftInfrai Console](https://console.crftinfrai.com)

## CrftInfrai

- Website: https://crftinfrai.com
- Console: https://console.crftinfrai.com
- GitHub: https://github.com/pawancrftinfrai

## Cost Warning

Running Terraform examples can create billable cloud resources. Always review `terraform plan`, cloud pricing, security requirements, and organizational policies before applying.

## License

Licensed under the Apache License 2.0. See [LICENSE](LICENSE).

This license applies only to code contained in this repository. It does not
grant rights to proprietary CrftInfrai Console source code or services.
