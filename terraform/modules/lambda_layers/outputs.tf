output "shapely_pyyaml_arn" {
  value       = aws_lambda_layer_version.shapely_pyyaml.arn
  description = "ARN of shapely_pyyaml lambda layer"
}