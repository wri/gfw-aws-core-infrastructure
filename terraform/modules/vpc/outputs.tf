output "id" {
  value       = aws_vpc.default.id
  description = "ID of the VPC."
}

output "public_subnets" {
  value       = aws_subnet.public
  description = "A list of VPC public subnets."
}

output "private_subnets" {
  value       = aws_subnet.private
  description = "A list of VPC private subnets."
}

output "public_subnet_ids" {
  value       = aws_subnet.public.*.id
  description = "A list of VPC public subnet IDs."
}

output "private_subnet_ids" {
  value       = aws_subnet.private.*.id
  description = "A list of VPC private subnet IDs."
}

output "public_subnet_az" {
  value       = aws_subnet.public.*.availability_zone
  description = "A list of VPC public subnet Availability Zones."
}

output "private_subnet_az" {
  value       = aws_subnet.private.*.availability_zone
  description = "A list of VPC private subnet Availability Zones."
}

output "bastion_hostname" {
  value       = aws_instance.bastion.public_dns
  description = "Bastion hostname for SSH access."
}

output "cidr_block" {
  value       = var.cidr_block
  description = "The CIDR range for the entire VPC."
}

output "nat_gateway_ips" {
  value       = [aws_eip.nat.*.public_ip]
  description = "Public IP addresses of the VPC NAT gateways."
}
