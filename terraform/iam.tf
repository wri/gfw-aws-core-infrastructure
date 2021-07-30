### IAM EMR roles needed for S3 bucket policy

data "template_file" "trust_emr" {
  template = file("${path.root}/templates/trust_service.json.tpl")
  vars = {
    service = "elasticmapreduce"
  }
}

data "template_file" "trust_ec2" {
  template = file("${path.root}/templates/trust_service.json.tpl")
  vars = {
    service = "ec2"
  }
}

data "local_file" "emr_default_policy" {
  filename = "${path.root}/templates/emr_default.json"
}

data "local_file" "emr_ec2_default_policy" {
  filename = "${path.root}/templates/emr_ec2_default.json"
}

resource "aws_iam_role" "iam_emr_service_role" {
  name               = "${var.project_prefix}-iam_emr_service_role"
  assume_role_policy = data.template_file.trust_emr.rendered
}

resource "aws_iam_role_policy" "iam_emr_service_policy" {
  name = "${var.project_prefix}-iam_emr_service_policy"
  role = aws_iam_role.iam_emr_service_role.id

  policy = data.local_file.emr_default_policy.content
}

resource "aws_iam_role" "iam_emr_profile_role" {
  name = "${var.project_prefix}-emr_profile"

  assume_role_policy = data.template_file.trust_ec2.rendered
}

resource "aws_iam_instance_profile" "emr_profile" {
  name = "${var.project_prefix}-emr_profile"
  role = aws_iam_role.iam_emr_profile_role.name
}

resource "aws_iam_role_policy" "iam_emr_profile_policy" {
  name = "${var.project_prefix}-iam_emr_profile_policy"
  role = aws_iam_role.iam_emr_profile_role.id

  policy = data.local_file.emr_ec2_default_policy.content
}


# Not sure what this is for but cannot delete it. So just keep it
resource "aws_iam_service_linked_role" "spot" {
  aws_service_name = "spot.amazonaws.com"
}