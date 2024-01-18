output "my_eip" {
  value = { for k, v in aws_eip.nat : k => v.public_ip }
}

output "webtier_alb" {
  value = aws_lb.webtier_alb.dns_name
}

output "application_alb" {
  value = aws_lb.apptier_alb.dns_name
}

output "database_endpoint" {
  value = aws_db_instance.database_instance.address
}

