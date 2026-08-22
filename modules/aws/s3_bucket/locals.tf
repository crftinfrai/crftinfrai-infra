locals {
  default_tags = {
    Project     = "CrftInfrai"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
