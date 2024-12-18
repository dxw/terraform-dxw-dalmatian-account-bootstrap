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
    external = {
      source  = "hashicorp/external"
      version = ">= 2.3.4"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = ">= 3.46.0"
    }
  }
}
