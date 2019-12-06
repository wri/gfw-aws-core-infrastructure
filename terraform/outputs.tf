output "environment" {
  value       = var.environment
  description = "Environment of current state."
}

//output "pipelines_bucket" {
//  value = aws_s3_bucket.pipelines.id
//}

output "bootstrap" {
  value = module.bootstrap
}