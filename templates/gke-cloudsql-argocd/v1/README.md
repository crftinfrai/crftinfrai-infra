# GKE + Cloud SQL + Argo CD — Google Cloud

This deterministic, single-file Terraform template creates a custom Google Cloud VPC, a regional VPC-native GKE cluster with private nodes, a private PostgreSQL Cloud SQL instance, and Argo CD installed through Helm.

## Architecture

```text
Google Cloud Project
├── Required APIs
├── Custom VPC
│   └── Regional GKE subnet
│       ├── Primary node range
│       ├── Pods secondary range
│       └── Services secondary range
├── Cloud Router + Cloud NAT
├── Private Services Access
│   └── Private PostgreSQL Cloud SQL
└── Regional GKE
    ├── Private worker nodes
    ├── Managed autoscaling node pool
    └── Argo CD Helm release
```

The GKE cluster and Cloud SQL instance share the VPC. Cloud SQL uses a reserved private-services range and a `servicenetworking.googleapis.com` connection instead of a public IP. Private GKE nodes use Private Google Access and Cloud NAT for required outbound access such as image pulls and Helm workloads.

## Resources created

- Required Compute Engine, Kubernetes Engine, Cloud SQL Admin, and Service Networking APIs
- Custom-mode VPC and regional GKE subnet
- Secondary IP ranges for GKE pods and services
- Cloud Router and Cloud NAT
- Private Services Access global address and service networking connection
- Regional VPC-native GKE cluster with private nodes
- Managed autoscaling GKE node pool with shielded nodes and Workload Identity
- Private PostgreSQL Cloud SQL instance, database, and user
- Helm release for Argo CD in the `argocd` namespace

## Prerequisites

- Terraform >= 1.5.0
- `gcloud` CLI and `kubectl`
- A Google Cloud project with billing enabled
- IAM permissions to enable the listed APIs and create the network, GKE, Cloud SQL, service networking, and regional resources
- Network access from the Terraform machine to the GKE control-plane endpoint

Authenticate with Application Default Credentials:

```bash
gcloud auth application-default login
gcloud config set project <project-id>
```

The Google provider uses `project_id` and `region`; it does not contain service-account JSON, credential paths, access tokens, or private keys.

## Configuration

All variables are defined in `main.tf`. Important variables include:

- `project_id`, `region`, `zones`, and `name_prefix`
- `network_name`, `subnet_name`, and `subnet_cidr`
- `pods_secondary_range_name`, `pods_secondary_cidr`, `services_secondary_range_name`, and `services_secondary_cidr`
- `cluster_name`, `release_channel`, and `master_authorized_cidrs`
- `gke_machine_type`, `gke_node_min_count`, `gke_node_max_count`, `gke_node_initial_count`, `gke_disk_size_gb`, and `gke_disk_type`
- `cloudsql_instance_name`, `cloudsql_database_name`, `cloudsql_version`, `cloudsql_tier`, and `cloudsql_disk_size_gb`

The default GKE cluster is regional in `us-central1`. The default node pool uses the listed three zones. The default master authorized network is `10.0.0.0/8`; replace `master_authorized_cidrs` with the actual private network or administrator egress CIDRs used to run Terraform and `kubectl`. `0.0.0.0/0` is rejected by variable validation.

## Database credentials

`db_password` is sensitive, defaults to `null`, and must be supplied through a protected variable or secret-injection workflow. Do not commit it to source control.

```bash
export TF_VAR_db_password='<password-from-your-secret-store>'
```

The password is used only for the Cloud SQL user and is never output. Protect Terraform state because sensitive provider-managed values can still be recorded there.

## Deployment

```bash
terraform init
terraform plan
terraform apply
```

Review the plan before applying. GKE, Cloud SQL, Cloud NAT, and other regional resources incur Google Cloud charges.

## Connect to GKE

The control-plane endpoint is public but restricted by `master_authorized_cidrs`, while worker nodes use private IPs:

```bash
gcloud container clusters get-credentials \
  <cluster-name> \
  --region <region> \
  --project <project-id>

kubectl get nodes
```

Use the `gke_cluster_name`, `gke_cluster_location`, and `project_id` Terraform outputs for the command values. Run the command from a network included in `master_authorized_cidrs`.

## Argo CD

Argo CD is installed by the `argocd` Helm release from `https://argoproj.github.io/argo-helm`, using chart `argo-cd` version `7.7.0` in the `argocd` namespace.

```bash
kubectl get pods -n argocd
kubectl get services -n argocd
```

The template does not output or document a default Argo CD password. Retrieve or rotate application credentials using the Kubernetes/Argo CD mechanisms appropriate for your environment.

## Cloud SQL

Cloud SQL PostgreSQL is private-only: `ipv4_enabled` is false and no authorized public networks are configured. Private Services Access connects the VPC to Google-managed Cloud SQL services, and the instance receives a private IP. Applications must run in a network location with VPC connectivity and should use the `cloudsql_private_ip` output or the Cloud SQL private hostname as appropriate.

## Destroy

```bash
terraform destroy
```

Cloud SQL deletion protection is enabled. To intentionally destroy the instance, first change `deletion_protection` in `main.tf` to `false` and apply that change, then run `terraform destroy`. Take and verify any required database backup before removal.

## Security notes

- GKE uses VPC-native networking, private worker nodes, shielded nodes, and Workload Identity.
- The GKE control plane is reachable only from configured master authorized networks; never add `0.0.0.0/0`.
- Cloud SQL has private IP only and no public authorized networks.
- The database password is sensitive, not hardcoded, and never output.
- Standard Google Cloud ADC is used; no static service-account keys or access tokens are stored.
- Cloud NAT provides controlled outbound access for private nodes and pod ranges.

## Production considerations

Review GKE release-channel and PostgreSQL version support in the selected region. Consider Cloud SQL regional high availability, Secret Manager integration, Cloud SQL Auth Proxy or connectors, stronger backup retention and restore testing, CMEK, Binary Authorization, network policy, GKE Gateway, and managed Prometheus. These are not provisioned by this focused template. Workload Identity is enabled, but application-specific Google service accounts and role bindings are intentionally left to the workload deployment.

## Cost warning

GKE, Cloud SQL, Cloud NAT, and regional networking are billable Google Cloud
services. Review node count, database tier, and NAT usage before applying.
