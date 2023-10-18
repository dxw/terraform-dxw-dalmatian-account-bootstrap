# Terraform project for account bootstrapping on dxw's Dalmatian hosting platform

[![Terraform CI](https://github.com/dxw/terraform-dxw-dalmatian-account-bootstrap/actions/workflows/continuous-integration-terraform.yml/badge.svg?branch=main)](https://github.com/dxw/terraform-dxw-dalmatian-account-bootstrap/actions/workflows/continuous-integration-terraform.yml?branch=main)

This project creates and manages resources within an AWS account to bootstrap it
for dxw's Dalmatian hosting platform.

## Usage

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.3 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.11.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.4.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.21.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_tfvars_s3"></a> [aws\_tfvars\_s3](#module\_aws\_tfvars\_s3) | github.com/dxw/terraform-aws-tfvars-s3 | v0.2.4 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_cloudwatch_log_group.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.cloudwatch_slack_alerts_lambda_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.cloudtrail_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cloudtrail_cloudwatch_logs_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.cloudtrail_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.cloudwatch_slack_alerts_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cloudtrail_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudtrail_cloudwatch_logs_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.cloudwatch_slack_alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.cloudwatch_slack_alerts_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_sns_topic.cloudwatch_slack_alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.sns_cloudwatch_slack_alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.cloudwatch_slack_alerts_lambda_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [archive_file.cloudwatch_slack_alerts_lambda](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region in which to launch resources | `string` | n/a | yes |
| <a name="input_cloudtrail_log_prefix"></a> [cloudtrail\_log\_prefix](#input\_cloudtrail\_log\_prefix) | Cloudtrail log prefix | `string` | n/a | yes |
| <a name="input_cloudtrail_log_retention"></a> [cloudtrail\_log\_retention](#input\_cloudtrail\_log\_retention) | Cloudtrail log retention in days. Set to 0 to keep all logs. | `number` | n/a | yes |
| <a name="input_cloudwatch_slack_alerts_channel"></a> [cloudwatch\_slack\_alerts\_channel](#input\_cloudwatch\_slack\_alerts\_channel) | The Slack channel for CloudWatch alerts | `string` | n/a | yes |
| <a name="input_cloudwatch_slack_alerts_hook_url"></a> [cloudwatch\_slack\_alerts\_hook\_url](#input\_cloudwatch\_slack\_alerts\_hook\_url) | The Slack webhook URL for CloudWatch alerts | `string` | n/a | yes |
| <a name="input_enable_cloudtrail"></a> [enable\_cloudtrail](#input\_enable\_cloudtrail) | Enable Cloudtrail | `bool` | n/a | yes |
| <a name="input_enable_cloudwatch_slack_alerts"></a> [enable\_cloudwatch\_slack\_alerts](#input\_enable\_cloudwatch\_slack\_alerts) | Enable CloudWatch Slack alerts. This creates an SNS topic to which alerts and pipelines can send messages, which are then picked up by a Lambda function that forwards them to a Slack webhook. | `bool` | n/a | yes |
| <a name="input_enable_s3_tfvars"></a> [enable\_s3\_tfvars](#input\_enable\_s3\_tfvars) | enable\_s3\_tfvars | `bool` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name to be used as a prefix for all resources | `string` | n/a | yes |
| <a name="input_tfvars_s3_enable_s3_bucket_logging"></a> [tfvars\_s3\_enable\_s3\_bucket\_logging](#input\_tfvars\_s3\_enable\_s3\_bucket\_logging) | Enable S3 bucket logging on the tfvars S3 bucket | `bool` | `true` | no |
| <a name="input_tfvars_s3_logging_bucket_retention"></a> [tfvars\_s3\_logging\_bucket\_retention](#input\_tfvars\_s3\_logging\_bucket\_retention) | tfvars S3 Logging bucket retention in days. Set to 0 to keep all logs. | `number` | `30` | no |
| <a name="input_tfvars_s3_tfvars_files"></a> [tfvars\_s3\_tfvars\_files](#input\_tfvars\_s3\_tfvars\_files) | Map of objects containing tfvar file paths | <pre>map(<br>    object({<br>      path = string<br>      key  = optional(string, "")<br>      }<br>  ))</pre> | `{}` | no |
| <a name="input_tfvars_s3_tfvars_restrict_access_user_ids"></a> [tfvars\_s3\_tfvars\_restrict\_access\_user\_ids](#input\_tfvars\_s3\_tfvars\_restrict\_access\_user\_ids) | List of AWS User IDs that require access to the tfvars S3 bucket. If left empty, all users within the AWS account will have access | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
