output "public_ip" {
  description = "Public IP of instance"
  value       = aws_instance.app_server.public_ip
}

output "key_path" {
  description = "Path to find SSH key"
  value       = "${path.module}/ec2-controller-private-key.pem"
}