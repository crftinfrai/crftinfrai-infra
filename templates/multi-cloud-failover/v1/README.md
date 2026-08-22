# What This Template Provides

This template provisions equivalent public static website storage in two clouds:

- AWS S3 as the primary site
- Google Cloud Storage as the secondary site

It is a **multi-cloud failover-ready infrastructure foundation**, not an automatic failover system. Terraform does not provision a global DNS provider, health-based traffic controller, or content replication pipeline.

## Providers used

- AWS
- Google Cloud

Authenticate each provider through its normal external mechanism. Terraform does not contain cloud credentials or keys.

## Failover model

The model is infrastructure-only, active/passive, and external/manual:

- AWS is the declared primary.
- Google Cloud is the declared secondary.
- Both static website buckets are provisioned and can serve the same logical site.
- No traffic-routing or health-check resource is provisioned.
- Automated failover requires an external DNS/global traffic controller configured to monitor both endpoints.

Deploying this Terraform alone does **not** create automatic failover.

## Architecture

```text
                 Traffic controller
                 (not provisioned)
                    /          \
                   /            \
                  v              v
        AWS S3 primary      GCS secondary
        static website      static website
```

Terraform creates the two storage-backed website targets only. It does not upload website files or create a cross-cloud dependency between them.

## Resources created

- AWS S3 bucket with website configuration and public object-read policy
- Google Cloud Storage bucket with website configuration and public object-read IAM
- Google Cloud Storage API enablement
- Outputs for both bucket names, regions, endpoints, providers, and failover mode

## Prerequisites

- Terraform >= 1.5.0
- AWS CLI and permissions to create the S3 resources
- `gcloud` CLI, a Google Cloud project with billing enabled, and permissions to enable Cloud Storage and create the bucket/IAM binding
- AWS authentication through a profile, environment credentials, or an attached IAM role
- Google Application Default Credentials

Examples:

```bash
aws configure --profile <profile-name>
export AWS_PROFILE=<profile-name>

gcloud auth application-default login
gcloud config set project <gcp-project-id>
```

## Configuration

Important variables include:

- `aws_region`: primary AWS region
- `gcp_project_id`: secondary Google Cloud project
- `gcp_region`: secondary Google Cloud location
- `name_prefix` and `environment`
- `aws_bucket_name`: globally unique S3 bucket name
- `gcp_bucket_name`: globally unique Google Cloud Storage bucket name

The default bucket names are examples and may already be taken. Override both names with globally unique values before applying.

## Application deployment

Terraform provisions the website infrastructure but does not upload `index.html`, `404.html`, or other application files. Deploy the same tested static artifact to both buckets through a separate CI/CD or release process.

For example, after building the site, use the provider-native upload tooling to publish the same content to the primary S3 bucket and secondary GCS bucket. Keep deployment and content replication procedures separate from this infrastructure template.

## Verify endpoints

After applying and uploading identical site content, inspect the real endpoints:

```bash
terraform output -raw primary_endpoint
terraform output -raw secondary_endpoint
```

The primary output comes from the S3 website configuration resource. The secondary URL is derived from the real GCS bucket name using the documented Cloud Storage object URL pattern.

## Manual failover procedure

This template does not perform traffic switching. A practical external/manual procedure is:

1. Detect and confirm that the AWS primary endpoint is unavailable.
2. Verify the GCS secondary endpoint and its content.
3. Update the external DNS or global traffic controller to route clients to the secondary endpoint.
4. Allow for DNS caching and TTL propagation; failover is not instantaneous.
5. Restore the primary site and decide whether to fail back after verification.

If an external controller is later added, configure real health checks against `/` or another path that the uploaded static site actually serves. This Terraform does not create those checks.

## Data and state replication

This template does not implement cross-cloud database replication or state synchronization. It creates no database. Static website content must be published consistently to both buckets by the application delivery process. Stateful failover requires a separate replication and recovery design.

## RTO and RPO

No RTO, RPO, uptime, zero-downtime, or zero-data-loss guarantee is provided. Actual recovery depends on content replication, health detection, DNS TTLs, external traffic management, and operator procedures.

## Security notes

- No cloud credentials, access keys, tokens, or secret outputs are present.
- The buckets are intentionally publicly readable because they are static website targets; upload permissions remain an operator/CI identity concern.
- `force_destroy = true` is enabled to make this reference environment easy to clean up; review this choice before using it for valuable content.
- No database, private network, cross-cloud VPN, or broad IAM role is created.

## Cost considerations

Both cloud buckets can incur storage and request charges simultaneously. This template avoids compute instances, Kubernetes, load balancers, NAT, VPNs, databases, and premium monitoring. Charges depend on stored content, requests, and data transfer.

## Destroy

```bash
terraform destroy
```

Because both buckets use `force_destroy = true`, Terraform can remove uploaded objects during destruction. Confirm that the content is disposable before destroying the environment.

## Terraform workflow

```bash
terraform init
terraform plan
terraform apply
```

Review both cloud provider changes before applying. Terraform does not upload
site content.

## Not included

The template intentionally does not provision automatic DNS failover, health checks, a global endpoint, cross-cloud replication, CI/CD, custom domains, CDN/WAF, databases, private networking, backup vaults, or centralized observability.
