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
