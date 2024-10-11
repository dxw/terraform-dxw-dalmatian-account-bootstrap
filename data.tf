data "aws_caller_identity" "current" {}

data "aws_regions" "current" {
  all_regions = true
}
