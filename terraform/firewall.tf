// DEFAUlT Security Group
// SSH in From WRI office and Developers home, 80 and 443 out

resource "aws_security_group" "default" {
  vpc_id = module.vpc.id
  name   = "${var.project}-default"
  tags = merge(
    {
      Name = "${var.project}-default"
    },
    local.tags
  )
}

resource "aws_security_group_rule" "office_ssh_ingress" {
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  cidr_blocks       = ["216.70.220.184/32"]
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "tmaschler_ssh_ingress" {
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  cidr_blocks       = ["${var.tmaschler_ip}/32"]
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "jterry_ssh_ingress" {
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  cidr_blocks       = ["${var.jterry_ip}/32"]
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "dmannarino_ssh_ingress" {
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  cidr_blocks       = ["${var.dmannarino_ip}/32"]
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "default_ssh_egress" {
  type      = "egress"
  from_port = "22"
  to_port   = "22"
  protocol  = "tcp"
  cidr_blocks = [
  module.vpc.cidr_block]

  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "default_http_egress" {
  type             = "egress"
  from_port        = "80"
  to_port          = "80"
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "default_https_egress" {
  type             = "egress"
  from_port        = "443"
  to_port          = "443"
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.default.id
}

// Webserver Security Group
// Ingress for port 80 and 443

resource "aws_security_group" "webserver" {
  vpc_id = module.vpc.id
  name   = "${var.project}-webserver"
  tags = merge(
    {
      Name = "${var.project}-webserver"
    },
    local.tags
  )
}

resource "aws_security_group_rule" "webserver_http_ingress" {
  type             = "ingress"
  from_port        = "80"
  to_port          = "80"
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.webserver.id
}

resource "aws_security_group_rule" "webserver_https_ingress" {
  type             = "ingress"
  from_port        = "443"
  to_port          = "443"
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.webserver.id
}