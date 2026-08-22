# Production EKS + RDS + Argo CD — AWS

This single-file Terraform template creates a private Amazon EKS cluster with a managed node group, a private PostgreSQL Amazon RDS instance, and Argo CD installed with the Helm provider. It is deterministic and does not require an LLM or any local Terraform modules.

## Architecture

The template creates one VPC spanning at least two availability zones:

```text
Internet Gateway
       |
  Public subnets — NAT Gateway per AZ
       |
  Private subnets — EKS control plane, nodes, and RDS
```

EKS and RDS use private subnets. Each private subnet has a route through its AZ's NAT Gateway for required outbound access, including EKS node bootstrap and Helm operations. The EKS Kubernetes API endpoint is private-only.

## Resources created

- VPC, DNS settings, public/private subnets, route tables, associations, internet gateway, NAT Gateways, and Elastic IPs
- IAM roles and AWS-managed policies for the EKS control plane and managed nodes
- EKS cluster and EKS managed node group
- Security groups for the cluster, nodes, and PostgreSQL RDS
- RDS subnet group and encrypted PostgreSQL DB instance
- Helm release for Argo CD in the `argocd` namespace

## Prerequisites

- Terraform >= 1.5.0
- AWS CLI credentials with permissions to create the listed VPC, IAM, EKS, RDS, and Helm-related resources
- Network access from the machine running Terraform to the private EKS API endpoint (for example, run Terraform from a connected VPC host, VPN, or bastion)
- Terraform providers can reach the AWS and Argo Helm registries during `terraform init`

## AWS authentication

The AWS provider uses `var.region` and does not contain credentials. Authenticate with an AWS CLI profile, environment variables such as `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, or an attached IAM role. Use the least-privileged deployment identity practical for your environment.

## Configuration

All variables have sensible defaults except `db_password`, which defaults to `null` and must be supplied securely. Important variables include `region`, `name_prefix`, `vpc_cidr`, `public_subnet_cidrs`, `private_subnet_cidrs`, `cluster_name`, `cluster_version`, `node_instance_types`, `node_capacity_type`, `node_desired_size`, `node_min_size`, `node_max_size`, `node_disk_size`, `db_engine_version`, `db_instance_class`, `db_allocated_storage`, `db_name`, `db_username`, and `db_password`.

Public and private subnet CIDR lists must contain at least two entries and are paired by availability zone. `db_instance_class` is an RDS class such as `db.t3.medium`; it is independent of the EKS EC2 `node_instance_types` such as `t3.large`.

## Database password handling

Do not commit the password to source control. Supply it through a protected tfvars file, an approved secret-injection workflow, or `TF_VAR_db_password`, for example:

```bash
export TF_VAR_db_password='use-a-secret-manager-or-ci-secret'
```

The variable is marked sensitive, and the password is never output. Terraform state can still contain the database password, so protect the state backend and access to state files.

## Deploy

```bash
terraform init
terraform plan
terraform apply
```

Review the plan before applying. NAT Gateways, EKS, and RDS incur AWS charges. A remote, encrypted Terraform state backend with locking is recommended for shared or production use.

## Connecting to EKS

Because the API endpoint is private-only, run this command from a network location that can resolve and reach the VPC endpoint:

```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
kubectl get nodes
```

The cluster endpoint and name are available from Terraform outputs.

## Checking Argo CD

```bash
kubectl -n argocd get pods
kubectl -n argocd get services
```

The `argo-cd` chart is installed from `https://argoproj.github.io/argo-helm` with chart version `7.7.0`. The release is named `argocd` and uses the `argocd` namespace.

## Destroy

RDS has deletion protection enabled and a final snapshot is configured. To intentionally remove the deployment, first change `deletion_protection` to `false` and apply, then run:

```bash
terraform destroy
```

Retain and protect the final database snapshot according to your data-retention policy.

## Security notes

- The EKS API is private-only; no public API CIDR is opened.
- RDS is private, encrypted at rest, not publicly accessible, and accepts TCP 5432 only from the EKS node security group.
- No database ingress is allowed from `0.0.0.0/0`.
- No credentials are hardcoded and the password is not output.
- The template does not create an OIDC/IRSA configuration because it is not required for this core deployment.

## Production considerations

Review Kubernetes and PostgreSQL engine versions against the AWS versions supported in your target region. Store state remotely with encryption and locking, use a managed secret workflow for `db_password`, restrict Terraform IAM permissions, and add organizational logging, alerting, backup/restore testing, and network egress controls. The private-only EKS API requires appropriate operator connectivity, and NAT Gateways have ongoing cost.
