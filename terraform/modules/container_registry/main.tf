# SOURCE: adopted from https://github.com/azavea/terraform-aws-ecr-repository

#
# ECR Resources
#
resource "aws_ecr_repository" "default" {
  name = "${var.project}-${var.repository_name}"
  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "default" {
  repository = aws_ecr_repository.default.name
  policy     = var.lifecycle_policy
}