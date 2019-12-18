resource "aws_iam_policy" "s3_write_pipelines" {
  name   = "${local.project}-s3_write_pipelines"
  policy = data.template_file.s3_write_pipelines.rendered
}

resource "aws_iam_policy" "s3_write_data-lake" {
  name   = "${local.project}-s3_write_data-lake"
  policy = data.template_file.s3_write_data-lake.rendered

}

resource "aws_iam_policy" "s3_write_tiles" {
  name   = "${local.project}-s3_write_tiles"
  policy = data.template_file.s3_write_tiles.rendered

}

resource "aws_iam_policy" "secrets_read_gfw-api-token" {
  name   = "${local.project}-secrets_read_gfw-api-token"
  policy = data.template_file.secrets_read_gfw-api-token.rendered
}