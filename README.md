# Azure App Platform

Provisions a production-ready Azure application platform with App Service, PostgreSQL Flexible Server, Key Vault, and full network isolation. All secrets are stored in Key Vault and accessed via managed identity; no credentials touch app config directly.

## Architecture

```
Internet
    |
    v
[ App Service ]  <-- system-assigned managed identity
    |   |
    |   +---> [ Key Vault ] (RBAC: Key Vault Secrets User)
    |              |
    |              +---> secret: db-admin-password
    |
    +---> [ PostgreSQL Flexible Server ] (private endpoint)
    |
    v
[ Log Analytics Workspace ] <-- diagnostic settings from all resources

All resources share a single VNet with three subnets:
  app-subnet   10.0.1.0/24  App Service VNet integration
  db-subnet    10.0.2.0/24  PostgreSQL Flexible Server (delegated)
  pe-subnet    10.0.3.0/24  Private endpoints (Key Vault, PostgreSQL)
```

## Modules

| Module | Path | What it provisions |
|---|---|---|
| networking | `./modules/networking` | VNet, three subnets, NSGs, private DNS zones for postgres |
| keyvault | `./modules/keyvault` | Key Vault (RBAC mode), private endpoint, diagnostic settings |
| sql | `./modules/sql` | PostgreSQL Flexible Server, initial database, KV secret for admin password, diagnostic settings |
| app-service | `./modules/app-service` | App Service Plan + Web App, VNet integration, Key Vault secret references for DB password, diagnostic settings |

Root module also provisions: Resource Group, Log Analytics Workspace, and the Key Vault Secrets User role assignment for the App Service managed identity.

## Usage

```hcl
module "app_platform" {
  source = "."

  subscription_id  = "00000000-0000-0000-0000-000000000000"
  app_name         = "myapp"
  environment      = "prod"
  db_admin_password = var.db_admin_password
}
```

See `example.tfvars` for a full variable reference.

```bash
terraform init
terraform plan -var-file="example.tfvars"
terraform apply -var-file="example.tfvars"
```

## Variables

### Required

| Name | Type | Description |
|---|---|---|
| `subscription_id` | string | Azure subscription ID |
| `app_name` | string | Base name used in all resource names |
| `environment` | string | `dev`, `staging`, or `prod` |
| `db_admin_password` | string (sensitive) | PostgreSQL administrator password |

### Optional

| Name | Type | Default | Description |
|---|---|---|---|
| `location` | string | `eastus2` | Azure region |
| `vnet_address_space` | list(string) | `["10.0.0.0/16"]` | VNet CIDR |
| `app_subnet_prefix` | string | `10.0.1.0/24` | App Service integration subnet |
| `db_subnet_prefix` | string | `10.0.2.0/24` | PostgreSQL subnet |
| `pe_subnet_prefix` | string | `10.0.3.0/24` | Private endpoints subnet |
| `app_service_sku` | string | `P1v3` | App Service Plan SKU |
| `db_sku` | string | `Standard_D2s_v3` | PostgreSQL Flexible Server compute SKU |
| `db_storage_mb` | number | `32768` | PostgreSQL storage (MB) |
| `db_admin_username` | string | `pgadmin` | PostgreSQL admin username |
| `db_name` | string | `appdb` | Initial database name |
| `kv_sku` | string | `standard` | Key Vault SKU (`standard` or `premium`) |
| `tags` | map(string) | `{}` | Extra tags merged onto all resources |

## Outputs

| Name | Description |
|---|---|
| `resource_group_name` | Name of the deployed resource group |
| `app_service_url` | Default hostname of the App Service |
| `key_vault_uri` | URI of the Key Vault |
| `db_host` | FQDN of the PostgreSQL Flexible Server |
| `vnet_id` | Resource ID of the virtual network |
| `log_analytics_workspace_id` | Resource ID of the Log Analytics workspace |

## Naming Convention

Resources follow the pattern `{app_name}-{environment}-{resource_suffix}`:

```
myapp-prod-rg        Resource group
myapp-prod-law       Log Analytics workspace
myapp-prod-kv        Key Vault
myapp-prod-vnet      Virtual network
myapp-prod-pg        PostgreSQL Flexible Server
myapp-prod-asp       App Service Plan
myapp-prod-app       Web App
```

## Security Notes

- **No public endpoints** — PostgreSQL and Key Vault are accessible only via private endpoints on `pe-subnet`.
- **Managed identity auth** — App Service uses a system-assigned managed identity. The `Key Vault Secrets User` RBAC role is granted at the Key Vault scope; no access policies are used.
- **DB password in Key Vault** — The admin password is stored as a Key Vault secret on first apply. The App Service references it via a Key Vault secret reference (`@Microsoft.KeyVault(...)`) so the value never appears in app settings in plaintext.
- **SSL enforced** — PostgreSQL SSL connections are required; no unencrypted connections are accepted.
- **NSG rules** — Each subnet has an NSG. Management ports are not open to the internet.
- **Soft-delete protection** — Key Vault purge-on-destroy is disabled; soft-deleted vaults are recovered automatically on re-deploy.

## Cost Estimates (default SKUs, East US 2)

| Resource | SKU | Est. monthly |
|---|---|---|
| App Service Plan | P1v3 | ~$140 |
| PostgreSQL Flexible Server | Standard_D2s_v3 + 32 GB | ~$130 |
| Key Vault | Standard (10k ops) | ~$5 |
| Log Analytics | PerGB2018, 90-day retention (varies) | ~$5–30 |
| **Total** | | **~$280–305/mo** |

For dev/staging, consider dropping to `B2` App Service SKU and `Burstable_B1ms` PostgreSQL, which cuts the bill to roughly $50–70/mo. Disable HA on PostgreSQL for non-prod environments.

## Requirements

| Name | Version |
|---|---|
| Terraform | >= 1.5.0 |
| hashicorp/azurerm | ~> 4.74.0 |
