# Contributing

1. Fork the repository and create a focused branch.
2. Make the change and update relevant documentation.
3. Run `terraform fmt -recursive`.
4. Run `terraform validate` for each affected Terraform root or module.
5. Open a pull request with a clear description and validation notes.

Never commit credentials, Terraform state files, production identifiers, customer information, or private environment files. Use placeholders and protected environment variables instead.
