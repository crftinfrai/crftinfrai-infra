# Azure Linux VM

Creates a Linux Azure VM with networking, security rules, optional public IP,
and optional DNS.

## Resources

Resource group, VNet/subnet or existing subnet, NIC, NSG, Linux VM, and optional
public IP/DNS resources.

## Requirements

Terraform >= 1.5 and the AzureRM provider declared in `versions.tf`.

## Usage

```hcl
module "vm" {
  source              = "./modules/azure/azure_vm"
  resource_group_name = "example-rg"
  location            = "eastus"
  vm_name             = "example-vm"
  ssh_public_key      = "ssh-ed25519 AAAA... example"
}
```

## Inputs

Resource/location names, network mode, CIDRs or existing subnet ID, image,
size, SSH users, public-IP, and DNS options.

## Outputs

See `outputs.tf` for the current VM, network, and DNS outputs.
