provider "aws" {
  region = local.aws_region

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "useast1"

  default_tags {
    tags = local.default_tags
  }
}

provider "datadog" {
  api_key  = local.datadog_api_key
  app_key  = local.datadog_app_key
  validate = local.datadog_api_key != "" && local.datadog_app_key != ""
  api_url  = local.datadog_api_url
}
