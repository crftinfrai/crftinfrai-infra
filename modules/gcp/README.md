# Google Cloud modules

Reusable Google Cloud Terraform modules:

- `gce_instance` — Compute Engine instance, network, firewall, and optional DNS.
- `gcp_cloudfunctions` — Cloud Functions v2 source bucket and function.
- `gcp_sql` — Cloud SQL database instance.
- `gcp_storage` — Cloud Storage bucket.
- `gke_cluster` — VPC, subnet, secondary ranges, and GKE cluster/node pool.

Supply the target project through variables or provider configuration. Use
Application Default Credentials, workload identity, or another supported
external mechanism; never commit service-account keys or project credentials.
