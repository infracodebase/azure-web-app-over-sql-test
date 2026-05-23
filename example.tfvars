subscription_id = "00000000-0000-0000-0000-000000000000"
location        = "eastus2"
environment     = "dev"
app_name        = "myapp"

vnet_address_space = ["10.0.0.0/16"]
app_subnet_prefix  = "10.0.1.0/24"
db_subnet_prefix   = "10.0.2.0/24"
pe_subnet_prefix   = "10.0.3.0/24"

app_service_sku = "P1v3"

db_sku            = "Standard_D2s_v3"
db_storage_mb     = 32768
db_admin_username = "pgadmin"
db_admin_password = "REPLACE_ME"
db_name           = "appdb"

kv_sku = "standard"

tags = {
  team    = "platform"
  project = "myapp"
}
