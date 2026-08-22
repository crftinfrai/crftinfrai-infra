# Cloud Run + Private Cloud SQL PostgreSQL — Google Cloud

This deterministic, single-file Terraform template creates a custom Google Cloud VPC, private-services access, a private PostgreSQL Cloud SQL instance, and a Cloud Run v2 service connected to the VPC through direct VPC egress.

## Architecture

```text
Internet or authenticated client
             |
        Cloud Run v2
             |
   Direct VPC egress: PRIVATE_RANGES_ONLY
             |
        Custom VPC subnet
             |
   Private Services Access
             |
   Private Cloud SQL PostgreSQL
```

Cloud Run uses a dedicated service account and reaches the Cloud SQL private IP through the custom VPC. Cloud Run does not receive a database password in its environment. Container stdout and stderr are collected automatically by native Cloud Logging.

## Resources created

- Required Cloud Run, Cloud SQL Admin, Compute Engine, Service Networking, and IAM APIs
- Custom-mode VPC and a subnet for Cloud Run direct VPC egress
- Private Services Access reserved range and `servicenetworking.googleapis.com` connection
- Private PostgreSQL Cloud SQL instance, database, and user
- Dedicated Cloud Run service account with `roles/cloudsql.client`
- Cloud Run v2 service with configurable scaling, VPC egress, container image, and non-secret database environment variables
- Optional conditional `roles/run.invoker` binding for `allUsers`

## Prerequisites

- Terraform >= 1.5.0
- `gcloud` CLI
- A Google Cloud project with billing enabled
- IAM permissions to enable the listed APIs and create the VPC, service networking, Cloud SQL, service account, IAM binding, and Cloud Run resources
- Application Default Credentials (ADC)

Authenticate with ADC, for example:

```bash
gcloud auth application-default login
gcloud config set project <project-id>
```

The Google provider uses normal ADC authentication. No service-account JSON, credential path, access token, or private key is stored in this template.

## Configuration

All variables are defined in `main.tf`. Important inputs include:

- `project_id`, `region`, `name_prefix`, `network_name`, and `vpc_subnet_cidr`
- `cloudrun_service_name`, `container_image`, `container_port`, `cloudrun_cpu`, and `cloudrun_memory`
- `cloudrun_min_instances`, `cloudrun_max_instances`, `cloudrun_timeout_seconds`, and `cloudrun_concurrency`
- `cloudrun_ingress` and `allow_unauthenticated`
- `cloudsql_instance_name`, `cloudsql_database_name`, `cloudsql_version`, `cloudsql_tier`, and `cloudsql_disk_size_gb`
- `db_username`, `db_password`, and non-secret `environment` values

The default container image is Google’s public Cloud Run hello sample, `us-docker.pkg.dev/cloudrun/container/hello`. Replace it with your application image before deployment. The default public ingress policy does not imply unauthenticated access: `allow_unauthenticated` defaults to `false`.

Cloud Run uses direct VPC egress with `PRIVATE_RANGES_ONLY`. Private ranges, including the Cloud SQL private address, route through the custom VPC; other outbound traffic uses Cloud Run’s normal egress path.

## Database credentials

`db_password` is sensitive, defaults to `null`, and must be supplied securely to create the Cloud SQL user:

```bash
export TF_VAR_db_password='<password-from-your-secret-store>'
```

Do not commit the password to source control. The value is not output and is not passed as a Cloud Run environment variable. For application runtime credentials, use Secret Manager with a future application-specific extension and grant only the required service-account access. Secret Manager is not provisioned by this template.

## Deployment

```bash
terraform init
terraform plan
terraform apply
```

Review the plan before applying. Cloud SQL and Cloud Run resources incur Google Cloud charges.

## Verify Cloud Run

The service URL is available from the `cloud_run_url` Terraform output:

```bash
terraform output -raw cloud_run_url
```

When `allow_unauthenticated = false`, requests require an identity with `roles/run.invoker`; the URL alone is not sufficient. When it is `true`, Terraform grants `roles/run.invoker` to `allUsers`.

## Cloud SQL

Cloud SQL PostgreSQL uses private IP only: `ipv4_enabled` is false and no public authorized networks are configured. Private Services Access connects the custom VPC to Google-managed Cloud SQL services. Cloud Run receives non-secret variables named `DB_HOST`, `DB_PORT`, `DB_NAME`, and `DB_USER`; it does not receive `DB_PASSWORD`.

The Cloud Run service account has the least-privilege `roles/cloudsql.client` role needed for Cloud SQL access. The application must use the private host and obtain its password through a secure runtime mechanism such as Secret Manager when credentials are needed.

## Logging

Cloud Run automatically sends container stdout and stderr to Cloud Logging. No custom logging resource is required by this template. Inspect logs in the Google Cloud console under Cloud Run or Logs Explorer, filtered by the Cloud Run service name.

## Scaling

Cloud Run instance scaling is controlled by `cloudrun_min_instances` and `cloudrun_max_instances`. The defaults allow scale-to-zero and up to five instances. `cloudrun_concurrency` controls the maximum concurrent requests per instance; this is instance scaling, not a fixed VM count.

## Destroy

```bash
terraform destroy
```

Cloud SQL deletion protection is enabled. To intentionally destroy the database, first change `deletion_protection` in `main.tf` to `false` and apply that change, then run `terraform destroy`. Take and verify any required database backup before removal.

## Security notes

- Cloud SQL is private-only and has no public authorized networks.
- Cloud Run uses direct VPC egress for private ranges.
- A dedicated Cloud Run service account receives only `roles/cloudsql.client`.
- No service-account key is created.
- The database password is sensitive, is not hardcoded, and is never output or passed to Cloud Run as plaintext environment data.
- Unauthenticated Cloud Run access is explicitly configurable and disabled by default.

## Production considerations

Review Cloud Run and PostgreSQL version support in the selected region. Consider Secret Manager, Artifact Registry, Cloud Armor or an external HTTPS load balancer, Cloud SQL regional high availability, CMEK, a custom domain, VPC Service Controls, Cloud SQL connectors, and observability dashboards. These features are not provisioned by this focused template.

## Cost warning

Cloud Run, Cloud SQL, networking, and logging are billable Google Cloud
services. Review the database tier and retention before applying.
