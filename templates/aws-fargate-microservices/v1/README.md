# AWS Fargate Microservices

This deterministic, single-file Terraform template creates an AWS VPC with public and private subnets, an Application Load Balancer, an ECS Fargate service, CloudWatch container logs, and CPU-based Application Auto Scaling.

## Architecture

```text
Internet
   |
Public subnets: Application Load Balancer + one NAT Gateway per AZ
   |
Private application subnets: ECS Fargate tasks
   |
CloudWatch Logs and external AWS/service endpoints through NAT
```

The ALB forwards HTTP traffic to Fargate tasks using an IP target group. Tasks receive no public IP addresses and use private subnet routes through a per-AZ NAT Gateway for outbound access.

## Resources created

- VPC with DNS support and DNS hostnames enabled
- Public and private subnets across at least two availability zones
- Internet Gateway, public route table, private route tables, Elastic IPs, and one NAT Gateway per AZ
- Separate ALB and ECS service security groups
- Application Load Balancer, HTTP listener, IP target group, and configurable health check
- ECS cluster with Container Insights enabled
- ECS task execution role and separate application task role
- Fargate task definition and ECS service
- CloudWatch Log Group with configurable retention
- ECS Application Auto Scaling target and CPU target-tracking policy

## Prerequisites

- Terraform >= 1.5.0
- AWS CLI
- AWS permissions to create the listed VPC, IAM, ECS, ELB, CloudWatch, NAT, and Application Auto Scaling resources
- A deployable container image accessible to Fargate

Authenticate through standard AWS mechanisms, such as an AWS CLI profile, environment variables, or an attached IAM role:

```bash
aws configure --profile <profile-name>
export AWS_PROFILE=<profile-name>
```

Do not place AWS access keys in Terraform configuration or source control.

## Configuration

All variables are defined in `main.tf`. Important inputs include:

- `region` and `name_prefix`
- `vpc_cidr`, `public_subnet_cidrs`, and `private_subnet_cidrs`
- `container_image`, `container_name`, and `container_port`
- `task_cpu` and `task_memory`
- `desired_count`, `min_capacity`, and `max_capacity`
- `health_check_path`, `alb_internal`, and `log_retention_days`
- `environment` for non-secret container environment variables

The public and private subnet CIDR lists must have the same number of entries and contain at least two entries. The default container image is the public Apache HTTPD sample image `public.ecr.aws/docker/library/httpd:2.4`; replace `container_image` with your application image before deployment. The default health check path `/` matches that sample image.

Do not put passwords, API tokens, or secret keys in `environment`. Use AWS Secrets Manager or SSM Parameter Store with ECS `secrets` configuration in an application-specific extension when secret injection is required; those services are not created by this template.

## Deploy

```bash
terraform init
terraform plan
terraform apply
```

Review the plan before applying. NAT Gateways, Fargate tasks, ALB traffic, and CloudWatch Logs incur AWS charges.

## Verify

After applying, get the ALB address from the `alb_dns_name` output:

```bash
curl "http://$(terraform output -raw alb_dns_name)/"
```

The default Apache image should return an HTTP response. If using another image, set `health_check_path` to an endpoint that the application actually serves.

## Logs

Container logs are sent through the `awslogs` driver to the CloudWatch Log Group named `/ecs/<name_prefix>`. The exact name is available from the `cloudwatch_log_group_name` output. Retention is controlled by `log_retention_days`.

## Scaling

`desired_count` controls the initial ECS service task count. Application Auto Scaling maintains the service between `min_capacity` and `max_capacity` using the `ECSServiceAverageCPUUtilization` target-tracking metric with a 60% target. The default desired and minimum capacity are 2, and the default maximum is 4.

## Networking

- The ALB is internet-facing by default and is placed in public subnets. Set `alb_internal = true` for an internal ALB reachable through private network paths.
- ECS tasks run in private application subnets with `assign_public_ip = false`.
- Public subnets route to the Internet Gateway.
- Each private subnet routes through the NAT Gateway in its own availability zone. This improves AZ independence but increases cost compared with a single NAT Gateway.

## Security

- The ALB security group allows HTTP on port 80.
- The ECS service security group allows the application port only from the ALB security group, not from the public internet.
- The ECS task execution role is separate from the application task role and has only the AWS-managed execution policy required for image/log operations.
- The application task role has no additional permissions by default.
- No AWS credentials or application secrets are hardcoded.

The base template is HTTP-only. Add ACM certificates, an HTTPS listener, redirects, and suitable ingress restrictions before exposing an internet-facing service to production traffic.

## Destroy

```bash
terraform destroy
```

Review the destruction plan carefully. NAT Gateways and Elastic IPs are removed with the deployment.

## Production considerations

Consider HTTPS with ACM, WAF, VPC endpoints for ECR and CloudWatch, private ECR repositories, Secrets Manager or SSM secret injection, ECS Exec with its required IAM and logging design, blue/green deployments, service discovery, and application-specific least-privilege task IAM. These features are not provisioned by this focused template.
