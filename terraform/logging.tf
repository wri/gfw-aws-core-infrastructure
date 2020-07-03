#
# CloudWatch Resources
#
resource "aws_cloudwatch_log_group" "batch_job" {
  name              = "/aws/batch/job"
  retention_in_days = 30
}
