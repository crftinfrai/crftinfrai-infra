# GCP Serverless Web App

This deterministic, single-file Terraform template creates a lightweight Google Cloud serverless web application using Cloud Run v2. It provisions the required APIs, a dedicated runtime service account, configurable Cloud Run scaling, and optional unauthenticated invocation.

## Architecture

```text
Client
  |
Cloud Run v2 service
  |
Native Google Cloud Logging
```

This template intentionally has no VPC, database, load balancer, connector, or NAT resources. It is the lightweight serverless webapp pattern; use the separate Cloud Run + Cloud SQL template when a private database backend is required.

## Resources created

- Cloud Run and IAM APIs enabled through `google_project_service`
- Dedicated Google service account for the Cloud Run runtime
- Cloud Run v2 service with configurable image, port, CPU, memory, timeout, concurrency, and instance scaling
- Conditional Cloud Run `roles/run.invoker` IAM member when unauthenticated access is enabled

Cloud Run container stdout and stderr are collected automatically by native Google Cloud Logging. No custom logging resource is required.

## Prerequisites

- Terraform >= 1.5.0
- `gcloud` CLI
- A Google Cloud project with billing enabled
- IAM permissions to enable the listed APIs, create a service account, create a Cloud Run service, and optionally grant `roles/run.invoker`
- A deployable container image compatible with Cloud Run

Authenticate with Application Default Credentials:

```bash
gcloud auth application-default login
gcloud config set project <project-id>
```

The Google provider uses standard ADC. No service-account JSON, credential path, access token, or refresh token is stored in this template.

## Configuration

All variables are defined in `main.tf`. Important inputs include:

- `project_id` and `region`
- `name_prefix` and `cloudrun_service_name`
- `container_image` and `container_port`
- `cloudrun_cpu` and `cloudrun_memory`
- `min_instances` and `max_instances`
- `request_timeout_seconds` and `container_concurrency`
- `allow_unauthenticated` and `ingress`
- Non-secret `environment` values and optional `labels`

The default container image is Google’s public Cloud Run hello sample, `us-docker.pkg.dev/cloudrun/container/hello`. Replace it with your application image before deployment. Do not put passwords, API keys, tokens, or credentials in `environment`.

## Deployment

```bash
terraform init
terraform plan
terraform apply
```

Review the plan before applying. Cloud Run charges are based on resource usage and configured instance behavior.

## Application image

Terraform provisions the Cloud Run service but does not build or publish application images. Replace the sample `container_image` with an image from your own build pipeline. Artifact Registry can be added later as a separate delivery concern; this template does not create a repository.

## Verify

The actual service URL is available from Terraform:

```bash
terraform output -raw cloud_run_url
```

With `allow_unauthenticated = false` (the default), requests require an identity with `roles/run.invoker`:

```bash
SERVICE_URL="$(terraform output -raw cloud_run_url)"
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" "$SERVICE_URL"
```

If `allow_unauthenticated = true`, Terraform grants `roles/run.invoker` to `allUsers`, and the URL can be accessed without an identity token.

## Scaling

Cloud Run scales between `min_instances` and `max_instances`. The defaults allow scale-to-zero and up to five instances. `container_concurrency` controls the maximum concurrent requests per instance, while `request_timeout_seconds` controls the request timeout.

## Logging

Cloud Run automatically sends container stdout and stderr to Google Cloud Logging. Inspect logs in the Cloud Run console or Logs Explorer, filtered by the Cloud Run service name.

## Security

- The service uses a dedicated runtime service account.
- No broad Owner, Editor, or project-admin role is granted.
- No static service-account key is created.
- Unauthenticated invocation is disabled by default and explicitly configurable.
- Cloud Run provides HTTPS at the service URL.
- No application secrets are hardcoded or output.

## Destroy

```bash
terraform destroy
```

Review the destruction plan carefully. The Cloud Run service and runtime service account are managed by Terraform; application images and external build artifacts are managed separately.

## Production considerations

Consider Artifact Registry, Secret Manager, custom domains, Cloud Armor or an HTTPS load balancer, Cloud CDN, private VPC egress, Cloud SQL, Redis, and alerting or dashboards as separate extensions when the application requires them. None of these resources are provisioned by this focused template.

## Cost warning

Cloud Run, storage, and logging can incur Google Cloud charges. Review scaling
and retention settings before applying.
