# Lightweight AWS Dev/Test Host

**THIS TEMPLATE IS FOR DEVELOPMENT / TESTING ONLY.**

This intentionally small AWS Terraform template creates one low-cost EC2 development host in a single public subnet. It is suitable for experiments, demos, temporary environments, learning, and simple HTTP testing. It is not production-ready.

## Purpose

The host bootstraps a basic nginx page so the deployment can be verified quickly. Replace the demo user data with your own development setup when needed.

## Architecture

```text
AWS Region
└── Single Availability Zone
    └── Small VPC
        └── One public subnet
            └── One small Amazon Linux EC2 instance
                └── nginx demo on HTTP port 80
```

The subnet routes directly through an Internet Gateway. The instance receives a public IP for easy temporary testing.

## Why it is low cost

- One `t3.micro` instance by default.
- One availability zone and one subnet.
- One 8 GiB encrypted gp3 root volume.
- No NAT Gateway.
- No load balancer.
- No database, Kubernetes, premium monitoring, or enterprise network appliance.
- Native EC2/system logging is available through the host; no separate paid monitoring stack is created.

## Resources created

- Custom VPC with DNS support and hostnames enabled
- Internet Gateway
- One public subnet and route table
- One security group allowing HTTP ingress
- One Amazon Linux 2023 EC2 instance
- One encrypted gp3 root volume managed with the instance

The AMI is selected dynamically from the regional AWS public SSM parameter for the latest Amazon Linux 2023 kernel-default image.

## Prerequisites

- Terraform >= 1.5.0
- AWS CLI
- AWS permissions to create VPC, EC2, IAM-read/SSM-read, and security group resources
- Standard AWS authentication through an AWS profile, environment variables, or an attached IAM role

For example:

```bash
aws configure --profile <profile-name>
export AWS_PROFILE=<profile-name>
```

Do not put AWS access keys or other credentials in Terraform files or source control.

## Configuration

All variables are defined in `main.tf`:

- `region`: AWS region, default `us-east-1`
- `name_prefix`: resource name prefix
- `environment`: tag value, default `dev`
- `vpc_cidr`: VPC CIDR block
- `subnet_cidr`: single public subnet CIDR
- `instance_type`: default `t3.micro`
- `root_volume_size_gb`: default 8 GiB
- `http_ingress_cidr`: CIDR allowed to access HTTP port 80; default `0.0.0.0/0` for simple demos

Restrict `http_ingress_cidr` to your office, VPN, or current public IP for a shared development environment. This template does not configure SSH access; add an approved access method deliberately if required.

## Deploy

```bash
terraform init
terraform plan
terraform apply
```

The instance installs nginx during first boot. Allow a short interval for package installation before testing the endpoint.

## Verify

Get the instance address:

```bash
terraform output -raw instance_public_ip
terraform output -raw instance_public_dns
```

Then open the IP or DNS name over HTTP, or run:

```bash
curl "http://$(terraform output -raw instance_public_ip)/"
```

## Destroy

This environment is intended to be temporary. Clean it up when finished to avoid ongoing EC2, EBS, and public IPv4 charges:

```bash
terraform destroy
```

The root volume is configured to be encrypted and deleted with the instance. Review the destroy plan before confirming.

## Security

- No cloud credentials or passwords are hardcoded.
- No database is created or exposed.
- The root volume is encrypted.
- HTTP access is controlled by `http_ingress_cidr`.
- No SSH port is opened by default.
- The instance has no broad IAM role or static key.

The default public HTTP CIDR is convenient for demos but should be restricted for anything shared. This remains a public, single-instance development host rather than a hardened service.

## Not included

This template intentionally omits high-availability and production features: multi-AZ deployment, autoscaling, load balancing, NAT Gateway, private networking, Kubernetes, managed databases, backup vaults, WAF, advanced monitoring, enterprise IAM, disaster recovery, and hardened CI/CD. Use a purpose-built production template for those requirements.
