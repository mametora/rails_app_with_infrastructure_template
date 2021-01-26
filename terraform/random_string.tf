resource "random_string" "alb_authorization" {
  length  = 16
  special = true
}

resource "random_string" "db_password" {
  length  = 16
  special = true
}
