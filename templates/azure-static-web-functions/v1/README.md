# Azure Static Web App + Functions

This deterministic, single-file Terraform template provisions an Azure Static Web App, a Linux Azure Function App, its consumption hosting plan and storage account, and workspace-backed Application Insights monitoring.

## Architecture

```text
User
  |
Azure Static Web App  ── frontend hosting
  |
Frontend application calls the separately deployed Function API
  |
Linux Azure Function App (HTTPS-only)
  |
Application Insights ── Log Analytics workspace ── Azure Monitor
```

Terraform provisions the Static Web App and Function App infrastructure. It does not deploy frontend source code or Function source code, and it does not create an automatic Static Web App-to-Function routing/linkage configuration. The frontend can call the Function App hostname from the Terraform output after configuring its API URL and CORS.

## Resources created

- Azure resource group
- Azure Static Web App with configurable SKU
- Standard LRS HTTPS-only storage account for Functions
- Linux `azurerm_service_plan` using the serverless `Y1` SKU
- Linux Node.js `azurerm_linux_function_app` with system-assigned managed identity
- Workspace-backed Log Analytics workspace
- Application Insights resource connected to that workspace

## Prerequisites

- Terraform >= 1.5.0
- Azure CLI
- Azure subscription with permission to create the listed resources
- Azure authentication through Azure CLI, environment credentials, or workload identity

Authenticate, for example:

```bash
az login
az account set --subscription "<subscription-id>"
```

No subscription credentials, client secrets, tenant secrets, or service-account keys are stored in this template.

## Configuration

All variables are defined in `main.tf`. Important inputs include:

- `location`, `resource_group_name`, and `name_prefix`
- `static_web_app_name`, `static_web_app_sku_tier`, and `static_web_app_sku_size`
- `function_app_name`, `function_runtime`, `function_runtime_version`, and `function_plan_name`
- `storage_account_name`, which must be globally unique, lowercase, alphanumeric, and 3-24 characters
- `application_insights_name`, `log_analytics_workspace_name`, and `log_retention_days`
- `cors_allowed_origins` and non-secret `environment` values

The Function App runtime is Node.js on Linux Functions v4. The default Static Web App, Function App, and storage account names may need to be changed because Azure name availability is global for some resource types.

## Deployment

```bash
terraform init
terraform plan
terraform apply
```

Review the plan before applying. Static Web Apps, Function Apps, storage, and Application Insights incur Azure charges according to their selected SKUs and usage.

## Frontend deployment

Terraform provisions the Azure Static Web App resource but does not upload frontend source code. Deploy the frontend separately through the Azure Static Web Apps deployment workflow or another supported CI/CD process. Do not hardcode a Static Web App deployment token in Terraform or source control.

## Function deployment

Terraform provisions the Function App host, storage, runtime, identity, and settings but does not package or upload Function source code. Deploy the Node.js Function application separately through your chosen CI/CD or Azure deployment process.

## Verify

Use Terraform outputs to find the actual hostnames:

```bash
terraform output -raw static_web_app_hostname
terraform output -raw function_app_hostname
```

The Function hostname is HTTPS-only. The Static Web App hostname is available after Azure creates the resource. The Function API must be deployed separately before it returns application responses.

## Monitoring

The Function App is connected to Application Insights through the `APPLICATIONINSIGHTS_CONNECTION_STRING` setting. Application Insights is workspace-backed by the Terraform-created Log Analytics workspace, with retention controlled by `log_retention_days`.

Function telemetry and application logs emitted by the deployed Node.js code can be inspected in Application Insights and the connected Log Analytics workspace. Static Web App hosting is provisioned, but this template does not claim full Static Web App application telemetry.

## Security

- Function App traffic requires HTTPS.
- The Function App uses a system-assigned managed identity.
- Storage enforces HTTPS-only traffic, TLS 1.2, and disables public nested-item access.
- No Azure credentials, deployment tokens, Function keys, storage keys, or client secrets are output.
- CORS is empty by default; set `cors_allowed_origins` to explicit frontend origins during deployment.
- Function authentication and API authorization are application concerns and are not fabricated by this infrastructure template.

The Function App uses its storage account access key internally because the AzureRM Function App resource requires it for this hosting pattern. The key is not exposed as an output or application setting.

## Destroy

```bash
terraform destroy
```

Review the destruction plan carefully. Static Web App and Function source deployments managed outside Terraform have their own release history and should be handled through the corresponding deployment workflow.

## Production considerations

Consider a custom domain, Azure Front Door or WAF, API Management, Key Vault-backed application secrets, private endpoints, Entra ID authentication, deployment slots, advanced alerts, and CI/CD policy controls before using this pattern for production traffic. These features are not provisioned by this focused template.

## Cost warning

Static Web Apps, Function hosting, storage, Application Insights, and Log
Analytics may incur Azure charges based on SKU and usage.
