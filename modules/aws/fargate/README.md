# Fargate cluster

Creates a minimal ECS cluster configured for Fargate capacity.

## Resources

One `aws_ecs_cluster` with Fargate capacity providers enabled by the current
module implementation.

## Requirements

Terraform >= 1.5 and the AWS provider declared in `versions.tf`.

## Usage

```hcl
module "fargate" {
  source       = "./modules/aws/fargate"
  aws_region   = "us-east-1"
  cluster_name = "example-fargate"
}
```

## Inputs

`aws_region` and `cluster_name`.

## Outputs

`cluster_id`.

## Notes

This compatibility module does not create a service, task definition, VPC, or
load balancer.
