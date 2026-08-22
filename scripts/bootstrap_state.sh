#!/usr/bin/env bash
set -euo pipefail

# Run this script from examples/bootstrap after setting the required Terraform
# variables (for example, TF_VAR_bucket_name and TF_VAR_dynamodb_table_name).
# It never stores credentials and never applies without a reviewed plan.

if [[ ! -f main.tf || ! -d ../../bootstrap/backend-state ]]; then
  echo "Run this script from examples/bootstrap." >&2
  exit 1
fi

terraform init -backend=false
terraform plan -out=tfplan
read -r -p "Apply this reviewed plan? Type 'yes' to continue: " answer
if [[ "$answer" != "yes" ]]; then
  echo "Apply cancelled."
  exit 0
fi
terraform apply tfplan
