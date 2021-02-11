// DEFAUlT Security Group
// SSH in From WRI office and Developers home, 80 and 443 out

resource "aws_security_group" "default" {
  vpc_id = var.vpc_id
  name   = "${var.project}-default"
  tags = merge(
    {
      Name = "${var.project}-default"
    },
    var.tags
  )
}

resource "aws_security_group_rule" "ingress_ssh" {
  count             = length(var.ssh_cidr_blocks)
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  cidr_blocks       = [var.ssh_cidr_blocks[count.index]]
  description       = var.description[count.index]
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "default_ssh_egress" {
  type      = "egress"
  from_port = "22"
  to_port   = "22"
  protocol  = "tcp"
  cidr_blocks = [
  var.vpc_cidre_block]

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
  vpc_id = var.vpc_id
  name   = "${var.project}-webserver"
  tags = merge(
    {
      Name = "${var.project}-webserver"
    },
    var.tags
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