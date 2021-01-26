resource "aws_ses_domain_identity" "default" {
  domain = var.zone
}

resource "aws_route53_record" "ses_verification_token" {
  zone_id = aws_route53_zone.default.zone_id
  name    = "_amazonses.${aws_route53_zone.default.name}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.default.verification_token]
}

resource "aws_ses_domain_dkim" "default" {
  domain = var.zone
}

resource "aws_route53_record" "dkim_record" {
  count   = 3
  zone_id = aws_route53_zone.default.zone_id
  name    = "${element(aws_ses_domain_dkim.default.dkim_tokens, count.index)}._domainkey.${aws_route53_zone.default.name}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.default.dkim_tokens, count.index)}.dkim.amazonses.com"]
}
