# EKS cluster

Creates an EKS control plane and managed node group with either module-owned
or existing network inputs.

## Resources

VPC/subnets and routes when requested, EKS cluster, IAM roles and policy
attachments, cluster security group, and managed node group.

## Requirements

Terraform >= 1.5 and the AWS provider declared in `versions.tf`.

## Usage

```hcl
module "eks" {
  source       = "./modules/aws/eks_cluster"
  cluster_name = "example-eks"
  aws_region   = "us-east-1"
  name_prefix  = "example"
}
```

## Inputs

Important inputs are `cluster_name`, `name_prefix`, `network_mode`, `azs`,
`existing_vpc_id`, `existing_subnet_ids`, Kubernetes version, endpoint access,
and node sizing variables.

## Outputs

`cluster_name`, `cluster_endpoint`, `cluster_ca`, `vpc_id`, `subnet_ids`, and
`node_group_name`.

## Notes

Review API access CIDRs before enabling public endpoint access.
