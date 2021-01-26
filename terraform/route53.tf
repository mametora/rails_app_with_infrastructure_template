resource "aws_route53_zone" "default" {
  name = var.zone
}

resource "aws_route53_record" "cloudfront" {
  zone_id = aws_route53_zone.default.zone_id
  name    = var.domain_name[terraform.workspace]
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.default.domain_name
    zone_id                = aws_cloudfront_distribution.default.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cloudfront_www" {
  count   = terraform.workspace == "prod" ? 1 : 0
  zone_id = aws_route53_zone.default.zone_id
  name    = "www"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.default.domain_name
    zone_id                = aws_cloudfront_distribution.default.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "alb" {
  zone_id = aws_route53_zone.default.zone_id
  name    = var.domain_name_lb[terraform.workspace]
  type    = "A"

  alias {
    name                   = aws_alb.default.dns_name
    zone_id                = aws_alb.default.zone_id
    evaluate_target_health = true
  }
}
