//
//resource "aws_lambda_function" "redirect_latest_tile_cache" { //TODO delete
//  //  function_name    = "${var.project}-redirect_latest_tile_cache"
//  function_name    = "redirect_latest_tile_cache"
//  filename         = module.tile_cache.lambda_redirect_latest_tile_cache_path
//  source_code_hash = module.tile_cache.lambda_redirect_latest_tile_cache_base64sha256
//  role             = module.tile_cache.lambda_edge_cloudfront_arn
//  runtime          = "nodejs8.10"
//  handler          = "index.handler"
//  memory_size      = 128
//  timeout          = 3
//  publish          = true
//  tags             = local.tags
//}
//
//resource "aws_lambda_function" "reset_response_header_caching" { //TODO delete
//  //  function_name    = "${var.project}-reset_response_header_caching"
//  function_name    = "reset_response_header_caching"
//  filename         = module.tile_cache.lambda_reset_response_header_caching_path
//  source_code_hash = module.tile_cache.lambda_reset_response_header_caching_base64sha256
//  role             = module.tile_cache.lambda_edge_cloudfront_arn
//  runtime          = "nodejs8.10"
//  handler          = "index.handler"
//  memory_size      = 128
//  timeout          = 1
//  publish          = true
//  tags             = local.tags
//}