resource "aws_s3_bucket_object" "shapely" {
  bucket = var.s3_bucket
  key    = "lambda_layers/shapely.zip"
  source = "../docker/shapely/layer.zip"
  etag   = filemd5("../docker/shapely/layer.zip")
}

resource "aws_s3_bucket_object" "rasterio" {
  bucket = var.s3_bucket
  key    = "lambda_layers/rasterio.zip"
  source = "../docker/rasterio/layer.zip"
  etag   = filemd5("../docker/rasterio/layer.zip")
}

resource "aws_s3_bucket_object" "pandas" {
  bucket = var.s3_bucket
  key    = "lambda_layers/pandas.zip"
  source = "../docker/pandas/layer.zip"
  etag   = filemd5("../docker/pandas/layer.zip")
}

resource "aws_lambda_layer_version" "shapely" {
  layer_name          = substr("${var.project}-shapely", 0, 64)
  s3_bucket           = aws_s3_bucket_object.shapely.bucket
  s3_key              = aws_s3_bucket_object.shapely.key
  compatible_runtimes = ["python3.6", "python3.7"]
}

resource "aws_lambda_layer_version" "rasterio" {
  layer_name          = substr("${var.project}-rasterio", 0, 64)
  s3_bucket           = aws_s3_bucket_object.rasterio.bucket
  s3_key              = aws_s3_bucket_object.rasterio.key
  compatible_runtimes = ["python3.6"]
}

resource "aws_lambda_layer_version" "pandas" {
  layer_name          = substr("${var.project}-pandas", 0, 64)
  s3_bucket           = aws_s3_bucket_object.pandas.bucket
  s3_key              = aws_s3_bucket_object.pandas.key
  compatible_runtimes = ["python3.6", "python3.7"]
}

