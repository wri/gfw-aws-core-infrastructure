output "environment" {
  value       = var.environment
  description = "Environment of current state."
}

output "pipelines_bucket" {
  value = aws_s3_bucket.pipelines.id
}

output "data-lake_bucket" {
  value = aws_s3_bucket.data-lake.id
}

output "tiles_bucket" {
  value = aws_s3_bucket.data-lake.id
}

output "tags" {
  value = local.tags
}

output "lambda_layer_shapely_pyyaml_arn" {
  value = module.lambda_layers.shapely_pyyaml_arn
}