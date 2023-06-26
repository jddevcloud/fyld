resource "aws_route53_record" "bastion" {
  zone_id =var.domain_zone_id
  name    = "b"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.bastion.public_ip]
}

resource "aws_route53_record" "rds" {
  zone_id =var.domain_zone_id
  name    = "db"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_db_instance.default.address]
}

output "bastion_host" {
  value = aws_route53_record.bastion.name
}
