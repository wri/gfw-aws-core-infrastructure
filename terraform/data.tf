data "aws_caller_identity" "current" {}


data "template_file" "trust_emr" {
  template = file("${path.root}/policies/trust_service.json.tpl")
  vars = {
    service = "elasticmapreduce"
  }
}

data "template_file" "trust_ec2" {
  template = file("${path.root}/policies/trust_service.json.tpl")
  vars = {
    service = "ec2"
  }
}

data "local_file" "emr_default_policy" {
  filename = "${path.root}/policies/emr_default.json"
}

data "local_file" "emr_ec2_default_policy" {
  filename = "${path.root}/policies/emr_ec2_default.json"
}
