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
