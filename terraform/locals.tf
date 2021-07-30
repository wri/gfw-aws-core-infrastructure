locals {
  bucket_suffix   = var.environment == "production" ? "" : "-${var.environment}"
  tf_state_bucket = "gfw-terraform${local.bucket_suffix}"
  tags = {
    Project     = var.project,
    Environment = var.environment,
    BuiltBy     = "Terraform"
  }
}