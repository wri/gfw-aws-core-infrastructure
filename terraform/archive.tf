
data "archive_file" "redirect_latest_tile_cache" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/redirect_latest_tile_cache/src"
  output_path = "${path.module}/lambda_functions/redirect_latest_tile_cache.zip"
}

data "archive_file" "reset_response_header_caching" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/reset_response_header_caching/src"
  output_path = "${path.module}/lambda_functions/reset_response_header_caching.zip"
}