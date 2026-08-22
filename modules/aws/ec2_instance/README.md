# EC2 instance

Creates an optional standalone public-subnet EC2 host with networking,
security group, storage, optional key pair, and optional Route 53 record.

## Resources

VPC/subnet or existing network references, internet routing, security group,
AMI data lookup, EC2 instance, optional EIP/EBS/key pair, and optional DNS.

## Requirements

Terraform >= 1.5 and the AWS provider declared in `versions.tf`.

## Usage

```hcl
module "vm" {
  source      = "./modules/aws/ec2_instance"
  aws_region  = "us-east-1"
  instance_name = "example-vm"
  ami_id      = "ami-xxxxxxxxxxxxxxxxx"
}
```

## Inputs

Important inputs include `aws_region`, `network_mode`, `vpc_cidr`,
`public_subnet_cidr`, `instance_type`, `ami_id`, `ssh_cidrs`, `user_data`,
and DNS/key-pair options.

## Outputs

`vpc_id`, `subnet_id`, `sg_id`, `instance_id`, `public_ip`, and `private_ip`.

## Notes

Use existing VPC/subnet and restrict `ssh_cidrs` for shared environments.
