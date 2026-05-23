locals {
  name_prefix = "${var.app_name}-${var.environment}"

  common_tags = merge(
    {
      environment = var.environment
      app_name    = var.app_name
      managed_by  = "terraform"
      creator     = "infracodebase"
    },
    var.tags
  )
}
