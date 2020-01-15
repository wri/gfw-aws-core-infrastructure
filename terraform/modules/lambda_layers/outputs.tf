output "shapely_pyyaml_arn" {
  value       = aws_lambda_layer_version.shapely_pyyaml.arn
  description = "ARN of shapely_pyyaml lambda layer"
}

output "rasterio_arn" {
  value       = aws_lambda_layer_version.rasterio.arn
  description = "ARN of rasterio lambda layer"
}