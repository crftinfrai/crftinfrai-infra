# AWS modules

Reusable AWS Terraform modules in this directory:

- `ec2_instance` — configurable EC2 host, networking, security group, and optional DNS.
- `ecs` — ECS cluster and service foundation.
- `eks_cluster` — EKS cluster and managed node group foundation.
- `fargate` — ECS Fargate service foundation.
- `lambda` — Lambda function and execution role.
- `rds_database` — RDS database instance and subnet/security configuration.
- `s3_bucket` — S3 bucket with configurable security and lifecycle settings.
- `vpc` — reserved compatibility path; currently empty and creates no resources.

Each module declares its AWS provider requirement in `versions.tf`. Authenticate
through the AWS CLI, environment, or workload identity; never put credentials in
module inputs or source control. See each module's `variables.tf` and
`outputs.tf` for its interface.
