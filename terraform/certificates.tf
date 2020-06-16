resource "aws_acm_certificate" "globalforestwatch" {
  domain_name       = "*.globalforestwatch.org"
  validation_method = "DNS"

  tags = merge({ "Name" = "Global Forest Watch Wildcard" },
  local.tags)

  lifecycle {
    create_before_destroy = true
  }
  count = var.environment == "production" ? 1 : var.environment == "staging" ? 1 : 0
}