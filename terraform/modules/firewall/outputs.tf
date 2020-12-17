output "default_security_group_id" {
  value = aws_security_group.default.id
}

output "webserver_security_group_id" {
  value = aws_security_group.webserver.id
}