#!/usr/bin/env bash
set -euo pipefail

# Run from a Terraform root. This helper deliberately separates planning from
# applying so an operator can inspect the exact proposed changes.

if [[ ! -f main.tf ]]; then
  echo "Run this script from a Terraform root containing main.tf." >&2
  exit 1
fi

terraform init
terraform plan -out=tfplan
read -r -p "Apply this reviewed plan? Type 'yes' to continue: " answer
if [[ "$answer" != "yes" ]]; then
  echo "Apply cancelled."
  exit 0
fi
terraform apply tfplan
