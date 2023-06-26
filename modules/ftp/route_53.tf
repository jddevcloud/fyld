resource "aws_route53_record" "ftp" {
  zone_id = var.domain_zone_id
  name    = "ftp"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.ftp.public_ip]
}

output "bastion_host" {
  value = aws_route53_record.ftp.name
}
