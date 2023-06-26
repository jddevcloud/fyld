# fyld.ai
resource "aws_route53_record" "mx" {
  zone_id = aws_route53_zone.fyld.zone_id
  name    = ""
  type    = "MX"
  ttl     = "300"
  records = [
    "1 ASPMX.L.GOOGLE.COM.",
    "5 ALT1.ASPMX.L.GOOGLE.COM.",
    "5 ALT2.ASPMX.L.GOOGLE.COM.",
    "10 ASPMX2.GOOGLEMAIL.COM.",
    "10 ASPMX3.GOOGLEMAIL.COM."
  ]
}

resource "aws_route53_record" "fyld-ai-gmail-dkim" {
  zone_id = aws_route53_zone.fyld.zone_id
  name    = "google-fyldai._domainkey"
  type    = "TXT"
  ttl     = "300"
  records = [
    "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmgz07WwbGFXkH9d3MqPNBPi8AmWg6313kGQgSK1TU9EYhJPw3C56hQhXFVjXW5P/5AHYUTvpgKadCmfcnCtL9ix3wrQJXBFwJ1HjQH3huVEHWIfxmyixLhiR1GV3p+\"\"UyqWyIgyeiIv+pgpa7pdC+GSKy4MC+KfcUuKNlOZTkop3yXRTCjpji/0/PZBkUP1kQOE8Rc+pNj0vB6aJnDQ833J/db8Qrqpsx3Rjqp7POgpwHHymxApZQGRGawq+juyU2D4GMFpHmCrRqD1AH63gVJcwyBgHVd73BobjJ81aOUNreXhzHGn2QkL6RilSz8e0WhwNJMX8Wx1vZ50zqAKImqQIDAQAB"
  ]
}

resource "aws_route53_record" "fyld-ai-gmail-dmarc" {
  zone_id = aws_route53_zone.fyld.zone_id
  name    = "_dmarc.fyld.ai"
  type    = "TXT"
  ttl     = "300"
  records = [
    "v=DMARC1; p=none; rua=mailto:dmarc-reports@fyld.ai"
  ]
}

# sitestream.app
resource "aws_route53_record" "gmail-mx" {
  zone_id = aws_route53_zone.domain.zone_id
  type    = "MX"
  name    = ""
  ttl     = "3600"

  records = [
    "1 aspmx.l.google.com.",
    "1 alt1.aspmx.l.google.com.",
    "5 alt2.aspmx.l.google.com.",
    "5 aspmx2.googlemail.com.",
    "10 alt3.aspmx.l.google.com.",
  ]
}

resource "aws_route53_record" "gmail-spf" {
  zone_id = aws_route53_zone.domain.zone_id
  type    = "SPF"
  name    = ""
  ttl     = "3600"
  records = ["v=spf1 include:_spf.google.com ~all"]
}

//resource "aws_route53_record" "gmail-domainkey" {
//  zone_id = aws_route53_zone.domain.zone_id
//  type    = "TXT"
//  name    = "google._domainkey"
//  ttl     = "3600"
//
//  records = [
//    "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6sqZBnAOFQ8LGaraK8n4JPpHHP5dz6n3y1IhMv7Llc35FVLN173gQzxNkFYaaYp7jEao6aMKrVcp7BEdMKdKZIO2ttuEH11NCbFzSLRV+EYxvePseYFjjmvvq3U3/HtVqzkQYiPum+/akMzlaoa9jo2Z66VdRMriMEG0pJKNPMKbyWLLLH/nNT6OpaDmEGyKe",
//    "U1xlThRof9jHf1LFncdEIz8ofdtAY/a9SfhNSdSg3RDxxTWnGErFwlFAOwzdLZcObNxy6l1pnkUMxock4cNPOwGMUjnYWCZ79bUFOL7Zql8OkPEbFVrLEMlcIbeGSrsvmfWd67IzKS0t46iKbrp/QIDAQAB",
//  ]
//}
