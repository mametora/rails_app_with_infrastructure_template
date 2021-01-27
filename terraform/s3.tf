resource "aws_s3_bucket" "default" {
  bucket = "${var.app_name}-${terraform.workspace}"
  acl    = "private"

  versioning {
    enabled = false
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT"]
    allowed_origins = ["https://${var.domain_name[terraform.workspace]}"]
    expose_headers  = [
      "Origin",
      "Content-Type",
      "Content-MD5",
      "Content-Disposition"
    ]
    max_age_seconds = 3600
  }

  tags = {
    Env     = terraform.workspace
    Product = var.app_name
  }
}

data "template_file" "s3_bucket_default_policy" {
  template = file("./bucket_policies/default.json")

  vars = {
    aws_cloudfront_origin_access_identity_id = aws_cloudfront_origin_access_identity.default.id
    bucket_arn                               = aws_s3_bucket.default.arn
  }
}

resource "aws_s3_bucket_policy" "default" {
  bucket = aws_s3_bucket.default.id
  policy = data.template_file.s3_bucket_default_policy.rendered
}
