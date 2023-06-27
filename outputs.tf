output "load_balancer_dns" {
  value = aws_lb.webserver-lb.dns_name
}

output "instance1_publicIP" {
  value = aws_instance.instance_1.public_ip
}

output "instance2_publicIP" {
  value = aws_instance.instance_2.public_ip
}

output "db_instance_address" {
  value = aws_db_instance.db_instance.address
}