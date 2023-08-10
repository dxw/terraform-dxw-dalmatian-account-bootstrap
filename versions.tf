terraform {
  required_version = ">= 1.5.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.11.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4.0"
    }
  }
}
