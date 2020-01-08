output "shapely_arn" {
  value       = aws_lambda_layer_version.shapely.arn
  description = "ARN of shapely lambda layer"
}

output "rasterio_arn" {
  value       = aws_lambda_layer_version.rasterio.arn
  description = "ARN of rasterio lambda layer"
}

output "pandas_arn" {
  value       = aws_lambda_layer_version.pandas.arn
  description = "ARN of pandas lambda layer"
}