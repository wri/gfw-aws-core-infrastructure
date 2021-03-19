resource "aws_sns_topic" "data_discovery_topic" {
  name = "dataset-discovery-${var.environment}"
}