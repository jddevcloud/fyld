resource "aws_route53_record" "pgbouncer" {
  zone_id = var.domain_zone_id
  name    = "pgbouncer"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.pgbouncer.public_ip]
}

output "bastion_host" {
  value = aws_route53_record.pgbouncer.name
}
