resource "aws_cloudfront_origin_access_identity" "default" {
  comment = "${var.app_name}-${terraform.workspace}-main"
}

resource "aws_cloudfront_distribution" "default" {

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.app_name}-${terraform.workspace}"
  aliases = [var.domain_name[terraform.workspace]]

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.default.arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  origin {
    domain_name = var.domain_name_lb[terraform.workspace]
    origin_id   = aws_alb.default.id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    custom_header {
      name  = "X-Pre-Shared-Key"
      value = random_string.alb_authorization.result
    }
  }

  origin {
    domain_name = aws_s3_bucket.default.bucket_domain_name
    origin_id   = aws_s3_bucket.default.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_alb.default.id
    compress         = true

    forwarded_values {
      query_string            = true
      query_string_cache_keys = []

      headers = [
        "Authorization",
        "Host"
      ]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"

    min_ttl     = 0
    default_ttl = 86400  # 24h
    max_ttl     = 604800 # 1week

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = aws_lambda_function.basic_auth.qualified_arn
    }
  }

  ordered_cache_behavior {
    path_pattern     = "/sitemap.xml.gz"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.default.id
    compress         = true

    forwarded_values {
      query_string            = false
      query_string_cache_keys = []

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"

    min_ttl     = 0
    default_ttl = 86400  # 24h
    max_ttl     = 604800 # 1week

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = aws_lambda_function.basic_auth.qualified_arn
    }
  }

  ordered_cache_behavior {
    path_pattern     = "/admin/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_alb.default.id
    compress         = true

    forwarded_values {
      query_string            = true
      query_string_cache_keys = []

      headers = [
        "Authorization",
        "Host",
        "Referer"
      ]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"

    min_ttl     = 0
    default_ttl = 86400  # 24h
    max_ttl     = 604800 # 1week

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = aws_lambda_function.basic_auth.qualified_arn
    }
  }
}
