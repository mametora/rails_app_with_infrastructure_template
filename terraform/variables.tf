variable "app_name" {
  default = "my-app"
}

variable "region" {
  default = "ap-northeast-1"
}

variable "zone" {
  default = "example.com"
}

variable "domain_name" {
  default = {
    prod = "example.com"
    stg  = "stg.example.com"
  }
}

variable "domain_name_lb" {
  default = {
    prod = "prod-lb.example.com"
    stg  = "stg-lb.example.com"
  }
}

variable "subject_alternative_names" {
  default = {
    prod = ["www.example.com"]
    stg  = []
  }
}

variable "rails_task_desired_count" {
  default = {
    prod = 2
    stg  = 1
  }
}

variable "sidekiq_task_desired_count" {
  default = {
    prod = 2
    stg  = 1
  }
}

variable "ecs_auto_scale_min" {
  default = {
    prod = 2
    stg  = 1
  }
}

variable "ecs_auto_scale_max" {
  default = {
    prod = 10
    stg  = 1
  }
}

variable "vpc_cidr" {
  default = {
    prod = "10.0.0.0/16"
    stg  = "10.1.0.0/16"
  }
}

variable "public_subnet_a_cidr" {
  default = {
    prod = "10.0.10.0/24"
    stg  = "10.1.10.0/24"
  }
}

variable "public_subnet_c_cidr" {
  default = {
    prod = "10.0.11.0/24"
    stg  = "10.1.11.0/24"
  }
}

variable "public_subnet_d_cidr" {
  default = {
    prod = "10.0.12.0/24"
    stg  = "10.1.12.0/24"
  }
}

variable "private_subnet_a_cidr" {
  default = {
    prod = "10.0.15.0/24"
    stg  = "10.1.15.0/24"
  }
}

variable "private_subnet_c_cidr" {
  default = {
    prod = "10.0.16.0/24"
    stg  = "10.1.16.0/24"
  }
}

variable "private_subnet_d_cidr" {
  default = {
    prod = "10.0.17.0/24"
    stg  = "10.1.17.0/24"
  }
}

variable "debug_ecs_instance_type" {
  default = "t3.small"
}

variable "debug_ecs_instance_price" {
  default = "0.0272"
}

variable "ecs_log_retention_period" {
  default = {
    prod = 90
    stg  = 3
  }
}

variable "lambda_edge_log_retention_period" {
  default = {
    prod = 3
    stg  = 1
  }
}

variable "aws_account_id" {
  default = "000000000000"
}

variable "rails_health_check_path" {
  default = "/health_check"
}

variable "db_instance_type" {
  default = {
    prod = "db.t3.small"
    stg  = "db.t3.small"
  }
}

variable "db_user" {
  default = "root"
}

variable "kvs_instance_type" {
  default = {
    prod = "cache.t3.small"
    stg  = "cache.t3.small"
  }
}

variable "kvs_number_cache_clusters" {
  default = {
    prod = 1
    stg  = 1
  }
}

variable "lambda_function" {
  default = {
    prod = "do_nothing"
    stg  = "basic_auth"
  }
}
