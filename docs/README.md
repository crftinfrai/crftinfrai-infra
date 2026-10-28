# Documentation

This directory contains repository-level guidance for using the CrftInfrai Terraform modules, architecture templates, and Kubernetes starters.

Use the README in each selected module, starter, and versioned template as the authoritative implementation guide. Before deployment, review provider authentication, variable defaults, Terraform state protection, cloud pricing, security notes, and cleanup instructions for the selected architecture.

## Start Here

| Goal | Guide |
| --- | --- |
| Design cloud infrastructure, estimate costs, and generate Terraform | [Cloud Infrastructure Generator](cloud-infrastructure-generator.md) |
| Understand the repository and choose a starting point | [Repository README](../README.md) |
| Compose an architecture from reusable services | [Terraform modules](../modules/) |
| Deploy a complete cloud architecture | [Architecture templates](../templates/) |
| Start with a security-focused Kubernetes foundation | [Kubernetes starters](../starters/) |
| Review example configuration and state bootstrap | [Examples](../examples/) and [state bootstrap](../bootstrap/) |

## Recommended Workflow

1. Select a module, starter, or versioned template that matches the workload.
2. Read its local README, provider requirements, variables, outputs, and security notes.
3. Review cloud region, service availability, identity permissions, network exposure, and expected costs.
4. Run formatting, initialization, validation, and a plan from the selected Terraform root.
5. Review the plan with your team before applying it.
6. Verify workload health, access controls, backups, monitoring, and recovery behavior after deployment.
7. Follow the template's cleanup instructions and check for retained billable resources.

For a visual design and cost estimation workflow, use the [CrftInfrai Cloud Infrastructure Builder](https://console.crftinfrai.com/cloud-infrastructure-builder) and [Cloud Cost Comparison](https://console.crftinfrai.com/compare). Review generated Terraform and its plan before provisioning.

## Validation Reminders

From a selected Terraform root, the usual checks are:

~~~
terraform fmt -check
terraform init -backend=false
terraform validate
terraform plan
~~~

The Terraform validate command checks configuration syntax and internal consistency after initialization. It does not verify cloud permissions, remote service availability, network connectivity, current provider support, or production readiness. The Terraform plan command evaluates the intended run against the configured account and variables; review its proposed additions, changes, replacements, deletions, and cost impact.

## Security and Operations

- Never commit credentials, sensitive variable files, Terraform state, or saved plans containing sensitive values.
- Use an approved secret-injection workflow for database passwords and other secrets.
- Protect remote state with access controls, encryption, and locking where supported.
- Restrict public endpoints, ingress CIDRs, IAM permissions, and Kubernetes access.
- Confirm that private Kubernetes API endpoints are reachable from the approved operator or CI environment.
- Review backup, restore, deletion protection, final snapshots, logging, monitoring, and recovery procedures.
- Treat examples and templates as starting points that require environment-specific review and testing.

Read the repository [security policy](../SECURITY.md) for vulnerability reporting and the [contribution guidelines](../CONTRIBUTING.md) before submitting changes.

## Related Resources

- [CrftInfrai platform](https://crftinfrai.com)
- [CrftInfrai Console](https://console.crftinfrai.com)
- [GitHub organization](https://github.com/crftinfrai)

