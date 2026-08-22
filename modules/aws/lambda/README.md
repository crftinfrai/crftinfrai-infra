# Lambda function

Creates an AWS Lambda function from a local package and its execution role.

## Resources

Lambda function, IAM execution role, and the AWS-managed basic execution
policy attachment.

## Requirements

Terraform >= 1.5 and the AWS provider declared in `versions.tf`.

## Usage

```hcl
module "function" {
  source   = "./modules/aws/lambda"
  name     = "example-function"
  filename = "${path.module}/function.zip"
}
```

## Inputs

Set `aws_region`, `name`, `filename`, `runtime`, `handler`, `architecture`,
`memory_size`, and `timeout`.

## Outputs

`function_name` and `function_arn`.

## Notes

The package file must exist before Terraform applies.
