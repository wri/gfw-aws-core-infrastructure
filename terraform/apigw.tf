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

resource "aws_security_group" "apigw" {
  vpc_id = module.vpc.id
  name   = "${var.project_prefix}-apigw"
  tags = merge(
    {
      Name = "${var.project_prefix}-apigw"
    },
    local.tags
  )
}

resource "aws_security_group_rule" "apigw_http_ingress" {
  type        = "ingress"
  from_port   = "80"
  to_port     = "80"
  protocol    = "tcp"
  cidr_blocks = [module.vpc.cidr_block]

  security_group_id = aws_security_group.apigw.id
}
resource "aws_security_group_rule" "apigw_https_ingress" {
  type        = "ingress"
  from_port   = "443"
  to_port     = "443"
  protocol    = "tcp"
  cidr_blocks = [module.vpc.cidr_block]

  security_group_id = aws_security_group.apigw.id
}

# User data script to bootstrap authorized ssh keys
data "template_file" "apigw_setup" {
  template = file("${path.module}/user_data/bastion_setup.sh.tpl")
  vars = {
    user                = "ec2-user"
    authorized_ssh_keys = <<EOT
%{for row in formatlist("echo \"%v\" >> /home/ec2-user/.ssh/authorized_keys", values(aws_key_pair.all)[*].public_key)~}
${row}
%{endfor~}
EOT
  }
}

resource "aws_instance" "apigw" {
  ami                         = data.aws_ami.amazon_linux_ami.id
  availability_zone           = module.vpc.public_subnet_az[0]
  ebs_optimized               = true
  instance_type               = "t3.large"
  monitoring                  = true
  subnet_id                   = module.vpc.public_subnets[0].id
  vpc_security_group_ids      = [module.firewall.default_security_group_id, aws_security_group.apigw.id]
  associate_public_ip_address = true
  user_data                   = data.template_file.apigw_setup.rendered

  lifecycle {
    ignore_changes = [ami]
  }

  tags = merge(
    {
      Name = "${var.project}-ApiGW"
    },
    local.tags
  )
}

resource "aws_eip" "apigw" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.apigw.id
  allocation_id = aws_eip.apigw.id
}

output "api_gw_hostname" {
    value = aws_instance.apigw.public_dns
}
output "api_gw_public_ip" {
    value = aws_instance.apigw.public_ip
}
output "api_gw_instance_arn" {
    value = aws_instance.apigw.arn
}