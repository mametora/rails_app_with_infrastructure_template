resource "aws_ecr_repository" "rails" {
  name = "${var.app_name}-${terraform.workspace}-rails"
}
