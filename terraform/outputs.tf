output "environment" {
  value       = var.environment
  description = "Environment of current state."
}

output "bootstrap" {
  value = module.bootstrap
}