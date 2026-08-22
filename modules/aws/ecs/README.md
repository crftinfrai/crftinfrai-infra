# ECS service

Creates a small ECS cluster and service with public subnets, security group,
task definition, and task execution role.

## Resources

VPC, public subnets and routes, ECS cluster/service/task definition, security
group, CloudWatch logging configuration, and execution IAM role.

## Requirements

Terraform >= 1.5 and the AWS provider declared in `versions.tf`.

## Usage

```hcl
module "service" {
  source          = "./modules/aws/ecs"
  cluster_name    = "example-cluster"
  service_name    = "example-service"
  container_name   = "web"
  container_image = "public.ecr.aws/docker/library/httpd:2.4"
}
```

## Inputs

Set `aws_region`, names, `container_image`, `container_port`, `desired_count`,
`vpc_cidr`, and `subnet_cidrs`.

## Outputs

`cluster_id`, `service_id`, and `task_definition_arn`.
