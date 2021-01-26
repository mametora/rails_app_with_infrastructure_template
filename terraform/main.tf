terraform {
  required_version = "~> 0.13.5"

  backend "s3" {
    bucket  = "my-app-tfstate"
    key     = "tf-state"
    encrypt = true
    region  = "ap-northeast-1"
  }
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}
