terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.92"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.1.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.6.1"
    }
  }

  required_version = ">= 1.2"
}