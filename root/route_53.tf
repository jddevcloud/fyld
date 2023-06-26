# fyld.ai
resource "aws_route53_zone" "fyld" {
  name = "fyld.ai"
}

resource "aws_route53_record" "webflow-cname" {
  zone_id = aws_route53_zone.fyld.zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = "300"
  records = ["fyld.wpengine.com"]
}

resource "aws_route53_record" "webflow-a" {
  zone_id = aws_route53_zone.fyld.zone_id
  name    = ""
  type    = "A"
  ttl     = "300"
  records = ["35.196.186.73"]
}

resource "aws_route53_record" "txt" {
  zone_id = aws_route53_zone.fyld.zone_id
  name    = ""
  type    = "TXT"
  ttl     = "300"
  records = [
    "google-site-verification=Kenip63-g329ozeDTtD7ekzOmbHhl63oab6ddq6iNV0",
    "v=spf1 include:_spf.google.com include:relay.mailchannels.net ~all",
    "google-site-verification=voaLioOJzdS2lqJI8XExb9mmXYxKsoJTacpKFcrmgsM",
    "google-site-verification=NZ2PQCMxBnWpdSQPHngNWXuZYvxE749Ntq5J7bgG7MI",
    "google-site-verification=1Vet7Pc34W2f41XA9r3WPbgw9qgvuPK7Z0BQ2FGkYUY"
  ]
}

# sitestream.app
resource "aws_route53_zone" "domain" {
  name = "sitestream.app"
}

resource "aws_route53_record" "staging-ns" {
  zone_id = aws_route53_zone.domain.zone_id
  name    = "staging"
  type    = "NS"
  ttl     = "300"

  records = [
    "ns-1623.awsdns-10.co.uk.",
    "ns-433.awsdns-54.com.",
    "ns-1321.awsdns-37.org.",
    "ns-932.awsdns-52.net.",
  ]
}

resource "aws_route53_record" "production-ns" {
  zone_id = aws_route53_zone.domain.zone_id
  name    = "production"
  type    = "NS"
  ttl     = "300"

  records = [
    "ns-1925.awsdns-48.co.uk.",
    "ns-40.awsdns-05.com.",
    "ns-1302.awsdns-34.org.",
    "ns-628.awsdns-14.net.",
  ]
}

resource "aws_route53_record" "sandbox-ns" {
  zone_id = aws_route53_zone.domain.zone_id
  name    = "sandbox"
  type    = "NS"
  ttl     = "300"

  records = [
    "ns-1986.awsdns-56.co.uk.",
    "ns-957.awsdns-55.net.",
    "ns-1180.awsdns-19.org.",
    "ns-402.awsdns-50.com.",
  ]
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.domain.zone_id
  name    = "api"
  type    = "CNAME"
  ttl     = "300"
  records = ["api.production.sitestream.app"]
}

resource "aws_route53_record" "static" {
  zone_id = aws_route53_zone.domain.zone_id
  name    = "static"
  type    = "CNAME"
  ttl     = "300"
  records = ["static.production.sitestream.app"]
}

resource "aws_route53_record" "media" {
  zone_id = aws_route53_zone.domain.zone_id
  name    = "media"
  type    = "CNAME"
  ttl     = "300"
  records = ["media.production.sitestream.app"]
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.domain.zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = "300"
  records = ["www.production.sitestream.app"]
}

resource "aws_route53_record" "sitestream-txt" {
  zone_id = aws_route53_zone.domain.zone_id
  name    = ""
  type    = "TXT"
  ttl     = "300"
  records = [
    "v=spf1 include:_spf.google.com ~all",
    "google-site-verification=WQvy7jX-nyglTERvYAII8XnIjFmJehBstFqsEHm2M4I",
    "google-site-verification=MxDrAo1wjY8UILYK4MSLajIhaRwBKuMFfADaYtBk58Q"
  ]
}

resource "aws_route53_record" "sitestream-open" {
  zone_id = aws_route53_zone.domain.zone_id
  name    = "open"
  type    = "CNAME"
  ttl     = "300"
  records = ["open.production.sitestream.app"]
}

# SES Verification
resource "aws_route53_record" "txt_ses_verification" {
  zone_id = aws_route53_zone.domain.zone_id
  name    = "_amazonses.sitestream.app"
  type    = "TXT"
  ttl     = "300"
  records = ["rkaAXL66Soi5cRIPvCLoJZf0s2Kr+ynp2Z6JM49k23Y="]
}

resource "aws_route53_record" "cname1_ses_verification" {
  zone_id = aws_route53_zone.domain.zone_id
  name    = "7ehmycvlyy6baeiabqtzmmnjsxszpn6f._domainkey.sitestream.app"
  type    = "CNAME"
  ttl     = "300"
  records = ["7ehmycvlyy6baeiabqtzmmnjsxszpn6f.dkim.amazonses.com"]
}

resource "aws_route53_record" "cname2_ses_verification" {
  zone_id = aws_route53_zone.domain.zone_id
  name    = "zqjun3cru6fed7teku4xar4vzkaquu67._domainkey.sitestream.app"
  type    = "CNAME"
  ttl     = "300"
  records = ["zqjun3cru6fed7teku4xar4vzkaquu67.dkim.amazonses.com"]
}

resource "aws_route53_record" "cname3_ses_verification" {
  zone_id = aws_route53_zone.domain.zone_id
  name    = "e6kyewfzd5idpgl4yeyhh6nphrcml6kk._domainkey.sitestream.app"
  type    = "CNAME"
  ttl     = "300"
  records = ["e6kyewfzd5idpgl4yeyhh6nphrcml6kk.dkim.amazonses.com"]
}

# SME DKIM

resource "aws_route53_record" "cname1_sme_ses_verification" {
  zone_id = aws_route53_zone.fyld.zone_id
  name    = "skn4u5rvtzgenaheogmegppk3kssmcyj._domainkey.fyld.ai"
  type    = "CNAME"
  ttl     = "300"
  records = ["skn4u5rvtzgenaheogmegppk3kssmcyj.dkim.amazonses.com"]
}

resource "aws_route53_record" "cname2_sme_ses_verification" {
  zone_id = aws_route53_zone.fyld.zone_id
  name    = "wap4dq3izb7h3tmeim4rj7vrsl2djvw2._domainkey.fyld.ai"
  type    = "CNAME"
  ttl     = "300"
  records = ["wap4dq3izb7h3tmeim4rj7vrsl2djvw2.dkim.amazonses.com"]
}

resource "aws_route53_record" "cname3_sme_ses_verification" {
  zone_id = aws_route53_zone.fyld.zone_id
  name    = "bbk5wirungyhtt35vljoxzkwamwpbl3p._domainkey.fyld.ai"
  type    = "CNAME"
  ttl     = "300"
  records = ["bbk5wirungyhtt35vljoxzkwamwpbl3p.dkim.amazonses.com"]
}

# Intercom
resource "aws_route53_record" "cname_intercom_verification" {
  zone_id = aws_route53_zone.fyld.zone_id
  name    = "intercom._domainkey.fyld.ai"
  type    = "CNAME"
  ttl     = "300"
  records = ["71053236-5d0c-4562-b77c-1a16e00d63e0.dkim.intercom.io"]
}

resource "aws_route53_record" "cname_intercom_outbound" {
  zone_id = aws_route53_zone.fyld.zone_id
  name    = "outbound.intercom.fyld.ai"
  type    = "CNAME"
  ttl     = "300"
  records = ["rp.fyld.intercom-mail.com"]
}

resource "aws_route53_record" "cname_intercom_help" {
  zone_id = aws_route53_zone.fyld.zone_id
  name    = "help.fyld.ai"
  type    = "CNAME"
  ttl     = "300"
  records = ["custom.intercom.help"]
}
