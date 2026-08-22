# S3 bucket

Creates one configurable Amazon S3 bucket.

## Resources

S3 bucket with the module's configured ownership, public-access-block, versioning,
encryption, lifecycle, and optional force-destroy settings.

## Requirements

Terraform >= 1.5 and the AWS provider declared in `versions.tf`.

## Usage

```hcl
module "bucket" {
  source      = "./modules/aws/s3_bucket"
  bucket_name = "example-unique-bucket-name"
}
```

## Inputs

`aws_region`, `bucket_name`, `environment`, and `force_destroy`.

## Outputs

`bucket_id` and `bucket_name`.

## Notes

S3 bucket names are globally unique. Treat `force_destroy` as destructive.
