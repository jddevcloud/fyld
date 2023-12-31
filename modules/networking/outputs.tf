output "private_subnets" {
  value = aws_subnet.private.*.id
}

output "public_subnets" {
  value = aws_subnet.public.*.id
}

output "protected_subnets" {
  value = aws_subnet.protected
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}
