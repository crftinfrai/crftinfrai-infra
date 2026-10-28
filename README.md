# CrftInfrai — Terraform Modules & Cloud Infrastructure Templates

Reusable Terraform modules, cloud architecture templates, and Kubernetes infrastructure starters for **AWS, Microsoft Azure, Google Cloud, and Oracle Cloud Infrastructure (OCI)**.

Use this repository to explore infrastructure patterns, configure a deployment, and review Terraform before provisioning. Use the hosted **CrftInfrai cloud infrastructure generator** to design infrastructure visually, compare cloud costs, and generate Terraform from your design.

[Open CrftInfrai Console](https://console.crftinfrai.com) · [Explore the Platform](https://crftinfrai.com/product) · [Browse Architecture Templates](#architecture-templates) · [Quick Start](#quick-start)

## What You Can Build

- **Kubernetes platforms:** Amazon EKS, Azure AKS, Google Kubernetes Engine (GKE), and OCI Kubernetes Engine (OKE).
- **Application infrastructure:** virtual machines, containers, serverless functions, and web application foundations.
- **Data services:** managed databases, PostgreSQL-backed application stacks, and object storage.
- **GitOps foundations:** Kubernetes architecture templates that combine managed clusters, databases, and Argo CD.
- **Development environments:** a small AWS EC2 development host and reusable cloud building blocks.

This repository contains infrastructure code and documentation. The hosted visual builder, cloud cost comparison, and AI Cost Intelligence services are separate CrftInfrai platform capabilities; their application source code is not included here.

## Choose Your Starting Point

| Your goal | Start here |
| --- | --- |
| Explore a small Terraform deployment | [AWS EC2 development environment](templates/lightweight-dev-test/v1/) |
| Assemble infrastructure from individual services | [Terraform modules](#terraform-modules) |
| Start from an application or platform architecture | [Architecture templates](#architecture-templates) |
| Review Kubernetes starters with security-focused defaults | [Kubernetes starters](#kubernetes-starters) |
| Design infrastructure visually and generate Terraform | [CrftInfrai Console](https://console.crftinfrai.com) |
| Review repository usage guidance | [Documentation](docs/README.md) |

## Supported Clouds

| Cloud | Kubernetes service | Module catalog |
| --- | --- | --- |
| Amazon Web Services (AWS) | Amazon EKS | [AWS Terraform modules](modules/aws/) |
| Microsoft Azure | Azure Kubernetes Service (AKS) | [Azure Terraform modules](modules/azure/) |
| Google Cloud (GCP) | Google Kubernetes Engine (GKE) | [GCP Terraform modules](modules/gcp/) |
| Oracle Cloud Infrastructure (OCI) | OCI Kubernetes Engine (OKE) | [OCI Terraform modules](modules/oci/) |

## Terraform Modules

Modules live under `modules/<cloud>/<module>`. Read the selected module's README, variables, outputs, and provider requirements before integrating it into your Terraform configuration.

| Cloud | Available modules |
| --- | --- |
| AWS | [EC2](modules/aws/ec2_instance/), [ECS](modules/aws/ecs/), [EKS](modules/aws/eks_cluster/), [Fargate](modules/aws/fargate/), [Lambda](modules/aws/lambda/), [RDS](modules/aws/rds_database/), [S3](modules/aws/s3_bucket/), [VPC](modules/aws/vpc/) |
| Azure | [Container Instances](modules/azure/azure_aci/), [AKS](modules/azure/azure_aks/), [Function App](modules/azure/azure_function/), [SQL](modules/azure/azure_sql/), [Storage](modules/azure/azure_storage/), [Virtual Machine](modules/azure/azure_vm/) |
| GCP | [Compute Engine](modules/gcp/gce_instance/), [Cloud Functions](modules/gcp/gcp_cloudfunctions/), [Cloud SQL](modules/gcp/gcp_sql/), [Cloud Storage](modules/gcp/gcp_storage/), [GKE](modules/gcp/gke_cluster/) |
| OCI | [Autonomous Database](modules/oci/oci_autonomous_db/), [Compute](modules/oci/oci_compute/), [Database](modules/oci/oci_db/), [Functions](modules/oci/oci_functions/), [Object Storage](modules/oci/oci_object_storage/), [OKE](modules/oci/oke/) |

## Architecture Templates

The versioned templates under `templates/` are Terraform root configurations. Each linked directory contains the template and its deployment guidance.

| Template | Cloud | Architecture |
| --- | --- | --- |
| [AKS + PostgreSQL + Monitoring](templates/aks-postgres-monitoring/v1/) | Azure | AKS, PostgreSQL, and monitoring foundation |
| [Fargate Microservices](templates/aws-fargate-microservices/v1/) | AWS | Fargate microservices foundation |
| [Static Web Apps + Functions](templates/azure-static-web-functions/v1/) | Azure | Static web application and serverless API foundation |
| [Cloud Run + Cloud SQL PostgreSQL](templates/cloudrun-cloudsql-postgres/v1/) | GCP | Cloud Run with private Cloud SQL PostgreSQL |
| [EKS + RDS + Argo CD](templates/eks-rds-argocd/v1/) | AWS | Managed Kubernetes, PostgreSQL RDS, and Argo CD foundation |
| [Serverless Web Application](templates/gcp-serverless-webapp/v1/) | GCP | Google Cloud serverless web application foundation |
| [GKE + Cloud SQL + Argo CD](templates/gke-cloudsql-argocd/v1/) | GCP | Managed Kubernetes, Cloud SQL, and Argo CD foundation |
| [Lightweight Development Environment](templates/lightweight-dev-test/v1/) | AWS | Small EC2 development host with supporting networking |
| [Multi-Cloud Static-Site Foundation](templates/multi-cloud-failover/v1/) | AWS + GCP | Static-site infrastructure for a failover-ready foundation |

Read each template's README for architecture, prerequisites, variables, cost considerations, limitations, and destroy instructions. The multi-cloud foundation should not be assumed to provide automatic failover without reviewing its configuration and operational requirements.

For programmatic discovery, use the [machine-readable template catalog](templates/index.json).

## Kubernetes Starters

These starters provide security-focused Kubernetes foundations. Review and adapt their defaults to your workload, access model, and organizational requirements.

| Starter | Included foundation |
| --- | --- |
| [Azure AKS Secure Starter](starters/azure-aks-secure/) | AKS with managed identity, RBAC, and PostgreSQL |
| [Google GKE Secure Starter](starters/gcp-gke-secure/) | Private GKE, Workload Identity, and private Cloud SQL |
| [OCI OKE Secure Starter](starters/oci-oke-secure/) | Private OKE network and node pool foundation |

## Quick Start

Start with the [lightweight AWS development template](templates/lightweight-dev-test/v1/README.md). It creates a small EC2 host and supporting network resources; it is intended for development and evaluation.

### 1. Clone the repository

```bash
git clone https://github.com/crftinfrai/crftinfrai-infra.git
cd crftinfrai-infra/templates/lightweight-dev-test/v1
```

### 2. Initialize and validate the configuration

Install Git and Terraform. This template requires Terraform `>= 1.5.0`; check the selected template for its provider requirements.

```bash
terraform init -backend=false
terraform validate
```

These commands initialize providers and check configuration validity. They do not provision infrastructure or establish production readiness.

### 3. Authenticate and review a plan

Configure AWS authentication using a supported CLI profile, environment variables, or workload identity. Review `main.tf` and the template README before planning, including region, instance size, network settings, and HTTP ingress.

```bash
terraform plan
```

Planning requires suitable cloud credentials and may query cloud APIs. The development template enables a public IP and defaults HTTP ingress to `0.0.0.0/0`; restrict `http_ingress_cidr` when appropriate.

No apply is included in this quick start. When you decide to provision, follow the template's deployment and cleanup instructions. For shared environments, configure an appropriate remote state backend and run `terraform init` with that backend before deployment.

## Cloud Infrastructure Generator

The [hosted CrftInfrai Console](https://console.crftinfrai.com) helps engineers move from an infrastructure design to Terraform that they can inspect and adapt.

The platform workflow is:

1. **Design** cloud infrastructure visually or start from an architecture template.
2. **Configure** resources and connections for your intended workload.
3. **Compare costs** before provisioning.
4. **Generate Terraform** and review the infrastructure configuration.
5. **Validate and deploy** through your team's approved Terraform workflow.

The public modules and templates in this repository can also be used directly without the hosted builder. Review the exported or repository-provided code, provider requirements, permissions, and deployment plan before applying it.

[Try the Cloud Infrastructure Builder](https://console.crftinfrai.com) · [Explore CrftInfrai Capabilities](https://crftinfrai.com/features)

## Cloud and AI Cost Intelligence

CrftInfrai also provides hosted tools for evaluating cloud infrastructure and AI workload economics:

- **Cloud cost comparison:** compare infrastructure requirements and estimated costs across AWS, Azure, GCP, and OCI.
- **LLM cost calculation and model comparison:** evaluate model pricing and forecast workload spend.
- **Cost per task and cost per successful task:** consider usage, retries, and success rates when comparing AI workload economics.

These are hosted platform capabilities. This repository does not contain a standalone LLM cost calculator or the hosted pricing service implementation.

[Explore AI Cost Intelligence and Cloud Cost Tools](https://crftinfrai.com/product)

## Repository Structure

| Directory | Purpose |
| --- | --- |
| [`modules/`](modules/) | Reusable Terraform modules organized by cloud |
| [`templates/`](templates/) | Versioned architecture root configurations |
| [`starters/`](starters/) | Kubernetes starting architectures with security-focused defaults |
| [`examples/`](examples/) | Example configurations and bootstrap root |
| [`bootstrap/`](bootstrap/) | Terraform state backend module |
| [`scripts/`](scripts/) | Workflow helpers; inspect each script before running it |
| [`docs/`](docs/) | Repository-level documentation |
| [`.github/workflows/`](.github/workflows/) | Repository automation, including Terraform validation and secret scanning |

## Deployment, Security, and Cost Considerations

Infrastructure templates are starting points. Production use requires environment-specific review and testing.

- Review Terraform and provider versions, cloud service availability, required permissions, and variable defaults.
- Inspect `terraform plan` before applying changes. Do not commit credentials, sensitive variable files, Terraform state, or saved plan files containing sensitive data.
- Protect Terraform state with appropriate access controls, encryption, and locking where supported.
- Check network exposure, identity permissions, logging, backups, and recovery requirements.
- Verify access to private Kubernetes API endpoints before running workflows that require them.
- Review cleanup instructions carefully. Database deletion protection, final snapshots, and retained resources can affect teardown and ongoing charges.

**Cloud resources can incur charges.** Depending on the template, costs may include compute, managed Kubernetes, databases, storage, NAT gateways, public IP addresses, and data transfer. Cost estimates depend on region, configuration, usage, and current provider pricing.

See the [security policy](SECURITY.md) for reporting security concerns.

## Frequently Asked Questions

### Can I use the Terraform templates without a CrftInfrai account?

Yes. You can clone and use the infrastructure code in this public repository without using the hosted console. Deployment still requires a cloud account, appropriate permissions, and any applicable cloud service charges.

### Does this repository include the visual infrastructure generator?

This repository contains Terraform modules, templates, starters, and supporting documentation. The visual infrastructure generator is available through the [CrftInfrai Console](https://console.crftinfrai.com); its application source code is not included.

### Where should I start with EKS, AKS, GKE, or OKE?

Use an individual [Terraform module](#terraform-modules) when composing your own configuration. Choose an [architecture template](#architecture-templates) or [Kubernetes starter](#kubernetes-starters) when you want a broader foundation.

### Are the templates ready for every production environment?

No single template covers every production requirement. Review security, availability, supported versions, observability, backup and recovery, state management, and cost before deployment. Terraform validation alone does not verify these requirements.

## Contributing

Improvements to documentation, examples, modules, and architecture templates are welcome. Read the [contribution guidelines](CONTRIBUTING.md) and [code of conduct](CODE_OF_CONDUCT.md) before contributing.

For bugs or feature suggestions, [open a GitHub issue](https://github.com/crftinfrai/crftinfrai-infra/issues). For security concerns, follow [SECURITY.md](SECURITY.md).

## About CrftInfrai

CrftInfrai connects cloud architecture design, infrastructure cost comparison, Terraform generation, AI Cost Intelligence, and governed Kubernetes operations.

- [Website](https://crftinfrai.com)
- [Platform Overview](https://crftinfrai.com/product)
- [Console](https://console.crftinfrai.com)
- [GitHub Organization](https://github.com/crftinfrai)

## License

Licensed under the Apache License 2.0. See [LICENSE](LICENSE).

This license applies only to code contained in this repository. It does not grant rights to proprietary CrftInfrai Console source code or services.


