data "aws_caller_identity" "current" {}


data "aws_ami" "amazon_linux_ami" {
  most_recent = true
  owners = [
  "amazon"]

  filter {
    name = "name"
    values = [
    "amzn2-ami-hvm*"]
  }
}


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


# User data script to bootstrap authorized ssh keys
data "template_file" "bastion_setup" {
  template = file("${path.module}/user_data/bastion_setup.sh.tpl")
  vars = {
    user = "ec2-user"
    authorized_ssh_keys = <<EOT
%{for row in formatlist("echo \"%v\" >> /home/ec2-user/.ssh/authorized_keys",
values(aws_key_pair.all)[*].public_key)~}
${row}
%{endfor~}
EOT
}
}