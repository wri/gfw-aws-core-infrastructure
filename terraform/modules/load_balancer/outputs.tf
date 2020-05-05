output "load_balancer_arn" {
  value = aws_lb.default.arn
}

output "data_api_listener_port" {
  value = var.data_api_listener_port
}

output "load_balancer_security_group_id" {
  value = aws_security_group.lb.id
}

output "data_api_container_port" {
  value = var.data_api_container_port
}

output "data_api_load_balancer_security_group_id" {
  value = aws_security_group.data_api_tasks.id
}

output "tile_cache_listener_port" {
  value = var.tile_cache_listener_port
}

output "tile_cache_container_port" {
  value = var.tile_cache_container_port
}

output "tile_cache_load_balancer_security_group_id" {
  value = aws_security_group.tile_cache_tasks.id
}