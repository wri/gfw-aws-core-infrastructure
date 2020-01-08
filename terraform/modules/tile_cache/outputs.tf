output "lambda_redirect_latest_tile_cache_qualified_arn" {
  value       = aws_lambda_function.redirect_latest_tile_cache.qualified_arn
  description = "Environment of current state."
}

output "lambda_redirect_latest_tile_cache_path" { //TODO delete
  value       = data.archive_file.redirect_latest_tile_cache.output_path
  description = "Environment of current state."
}

output "lambda_redirect_latest_tile_cache_base64sha256" { //TODO delete
  value       = data.archive_file.redirect_latest_tile_cache.output_base64sha256
  description = "Environment of current state."
}

output "lambda_reset_response_header_caching_qualified_arn" {
  value       = aws_lambda_function.reset_response_header_caching.qualified_arn
  description = "Environment of current state."
}

output "lambda_reset_response_header_caching_path" { //TODO delete
  value       = data.archive_file.reset_response_header_caching.output_path
  description = "Environment of current state."
}

output "lambda_reset_response_header_caching_base64sha256" { //TODO delete
  value       = data.archive_file.reset_response_header_caching.output_base64sha256
  description = "Environment of current state."
}

output "lambda_edge_cloudfront_arn" {
  value       = aws_iam_role.lambda_edge_cloudfront.arn
  description = "Environment of current state."
}

output "cloudfront_origin_access_identity_iam_arn" {
  value = aws_cloudfront_origin_access_identity.tiles.iam_arn
  description = "IAM ARN of Cloud Front Origin Access Identity"
}