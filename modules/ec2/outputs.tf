output "public_ip" {
  description = "Public IP to ssh."
  value = aws_instance.example.public_ip
}

output "instance_state" {
  description = "Public IP to ssh."
  value = aws_instance.example.instance_state
}
