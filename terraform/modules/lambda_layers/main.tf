
resource "aws_s3_bucket_object" "shapely_pyyaml" {
  bucket = var.s3_bucket
  key    = "lambda_layers/shapely_pyyaml.zip"
  source = "../docker/shapely_pyyaml/layer.zip"
  etag   = filemd5("../docker/shapely_pyyaml/layer.zip")
}

resource "aws_lambda_layer_version" "shapely_pyyaml" {
  layer_name          = substr("${var.project}-shapely_pyyaml", 0, 64)
  s3_bucket           = aws_s3_bucket_object.shapely_pyyaml.bucket
  s3_key              = aws_s3_bucket_object.shapely_pyyaml.key
  compatible_runtimes = ["python3.7"]
}

