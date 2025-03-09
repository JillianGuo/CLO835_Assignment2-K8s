output "public_ip" {
  value = aws_instance.my_amazon.public_ip
}

output "ec2_instance_id" {
  value = aws_instance.my_amazon.id
}
