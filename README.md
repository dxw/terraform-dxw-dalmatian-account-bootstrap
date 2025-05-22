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
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | >= 3.46.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | >= 2.3.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.7.1 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.98.0 |
| <a name="provider_aws.useast1"></a> [aws.useast1](#provider\_aws.useast1) | 5.98.0 |
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | >= 3.46.0 |
| <a name="provider_external"></a> [external](#provider\_external) | >= 2.3.4 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_tfvars_s3"></a> [aws\_tfvars\_s3](#module\_aws\_tfvars\_s3) | github.com/dxw/terraform-aws-tfvars-s3 | v0.2.6 |

## Resources

| Name | Type |
|------|------|
| [aws_athena_named_query.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_named_query) | resource |
| [aws_athena_workgroup.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_workgroup) | resource |
| [aws_cloudtrail.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_cloudwatch_log_group.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.cloudwatch_slack_alerts_lambda_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.delete_default_resources_lambda_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_codestarconnections_connection.connections](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codestarconnections_connection) | resource |
| [aws_glue_catalog_database.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_database) | resource |
| [aws_glue_catalog_table.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_table) | resource |
| [aws_iam_openid_connect_provider.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.cloudtrail_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cloudwatch_slack_alerts_logs_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.datadog_aws_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.datadog_aws_integration_resource_collection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.delete_default_resources_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.delete_default_resources_vpc_delete_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ssm_dhmc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.cloudtrail_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.cloudwatch_slack_alerts_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.datadog_aws_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.delete_default_resources_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ssm_dhmc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cloudtrail_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_slack_alerts_logs_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.datadog_aws_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.datadog_aws_integration_resource_collection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.datadog_aws_integration_security_audit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.delete_default_resources_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.delete_default_resources_vpc_delete_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_dhmc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.athena_cloudtrail_output](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.cloudtrail_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.cloudwatch_opsgenie_alerts_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.cloudwatch_opsgenie_alerts_sns_us_east_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.cloudwatch_slack_alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.delete_default_resources_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.athena_cloudtrail_output](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.cloudtrail_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.cloudwatch_opsgenie_alerts_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.cloudwatch_opsgenie_alerts_sns_us_east_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.cloudwatch_slack_alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.delete_default_resources_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lambda_function.cloudwatch_slack_alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.delete_default_resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.cloudwatch_slack_alerts_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_route53_zone.root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_s3_bucket.athena_cloudtrail_output](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.athena_cloudtrail_output](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.athena_cloudtrail_output](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_logging.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.athena_cloudtrail_output](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.athena_cloudtrail_output](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.athena_cloudtrail_output](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.athena_cloudtrail_output](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_sns_topic.cloudwatch_opsgenie_alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.cloudwatch_opsgenie_alerts_us_east_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.cloudwatch_slack_alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.sns_cloudwatch_opsgenie_alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.sns_cloudwatch_opsgenie_alerts_us_east_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.sns_cloudwatch_slack_alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.cloudwatch_opsgenie_alerts_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sns_topic_subscription.cloudwatch_opsgenie_alerts_subscription_us_east_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sns_topic_subscription.cloudwatch_slack_alerts_lambda_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_ssm_service_setting.ssm_dhmc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_service_setting) | resource |
| [datadog_integration_aws_account.aws](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_aws_account) | resource |
| [datadog_integration_aws_external_id.aws](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_aws_external_id) | resource |
| [archive_file.cloudwatch_slack_alerts_lambda](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.delete_default_resources_lambda](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [external_external.oidc_certificate_thumbprint](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region in which to launch resources | `string` | n/a | yes |
| <a name="input_cloudtrail_athena_glue_tables"></a> [cloudtrail\_athena\_glue\_tables](#input\_cloudtrail\_athena\_glue\_tables) | Create the Glue database and tables for CloudTrail to be used with Athena | `bool` | n/a | yes |
| <a name="input_cloudtrail_athena_s3_output_kms_encryption"></a> [cloudtrail\_athena\_s3\_output\_kms\_encryption](#input\_cloudtrail\_athena\_s3\_output\_kms\_encryption) | Use KMS encryption with the CloudTrail Athena output S3 bucket | `bool` | n/a | yes |
| <a name="input_cloudtrail_athena_s3_output_retention"></a> [cloudtrail\_athena\_s3\_output\_retention](#input\_cloudtrail\_athena\_s3\_output\_retention) | CloudTrail Athena Set to 0 to keep all logs | `number` | n/a | yes |
| <a name="input_cloudtrail_kms_encryption"></a> [cloudtrail\_kms\_encryption](#input\_cloudtrail\_kms\_encryption) | Use KMS encryption with CloudTrail | `bool` | n/a | yes |
| <a name="input_cloudtrail_log_prefix"></a> [cloudtrail\_log\_prefix](#input\_cloudtrail\_log\_prefix) | Cloudtrail log prefix | `string` | n/a | yes |
| <a name="input_cloudtrail_log_retention"></a> [cloudtrail\_log\_retention](#input\_cloudtrail\_log\_retention) | Cloudtrail log retention in days. Set to 0 to keep all logs. | `number` | n/a | yes |
| <a name="input_cloudtrail_s3_access_logs"></a> [cloudtrail\_s3\_access\_logs](#input\_cloudtrail\_s3\_access\_logs) | Enable CloudTrail S3 bucket access logging | `bool` | n/a | yes |
| <a name="input_cloudwatch_opsgenie_alerts_sns_endpoint"></a> [cloudwatch\_opsgenie\_alerts\_sns\_endpoint](#input\_cloudwatch\_opsgenie\_alerts\_sns\_endpoint) | The Opsgenie SNS endpoint. https://support.atlassian.com/opsgenie/docs/integrate-opsgenie-with-incoming-amazon-sns/ | `string` | n/a | yes |
| <a name="input_cloudwatch_opsgenie_alerts_sns_kms_encryption"></a> [cloudwatch\_opsgenie\_alerts\_sns\_kms\_encryption](#input\_cloudwatch\_opsgenie\_alerts\_sns\_kms\_encryption) | Use KMS encryption with the Opsgenie Alerts SNS topic | `bool` | n/a | yes |
| <a name="input_cloudwatch_slack_alerts_channel"></a> [cloudwatch\_slack\_alerts\_channel](#input\_cloudwatch\_slack\_alerts\_channel) | The Slack channel for CloudWatch alerts | `string` | n/a | yes |
| <a name="input_cloudwatch_slack_alerts_hook_url"></a> [cloudwatch\_slack\_alerts\_hook\_url](#input\_cloudwatch\_slack\_alerts\_hook\_url) | The Slack webhook URL for CloudWatch alerts | `string` | n/a | yes |
| <a name="input_cloudwatch_slack_alerts_kms_encryption"></a> [cloudwatch\_slack\_alerts\_kms\_encryption](#input\_cloudwatch\_slack\_alerts\_kms\_encryption) | Use KMS encryption with the Slack Alerts SNS topic and logs | `bool` | n/a | yes |
| <a name="input_cloudwatch_slack_alerts_log_retention"></a> [cloudwatch\_slack\_alerts\_log\_retention](#input\_cloudwatch\_slack\_alerts\_log\_retention) | Cloudwatch Slack Alerts log retention. Set to 0 to keep all logs | `number` | n/a | yes |
| <a name="input_codestar_connections"></a> [codestar\_connections](#input\_codestar\_connections) | CodeStar connections to create | <pre>map(<br/>    object({<br/>      provider_type = string,<br/>    })<br/>  )</pre> | n/a | yes |
| <a name="input_custom_iam_roles"></a> [custom\_iam\_roles](#input\_custom\_iam\_roles) | Configure custom IAM roles/policies | <pre>map(object({<br/>    description = string<br/>    policies = map(object({<br/>      description = string<br/>      policy      = string<br/>    }))<br/>    assume_role_policy = string<br/>  }))</pre> | n/a | yes |
| <a name="input_datadog_api_key"></a> [datadog\_api\_key](#input\_datadog\_api\_key) | Datadog API key | `string` | n/a | yes |
| <a name="input_datadog_app_key"></a> [datadog\_app\_key](#input\_datadog\_app\_key) | Datadog App key | `string` | n/a | yes |
| <a name="input_datadog_region"></a> [datadog\_region](#input\_datadog\_region) | Datadog region | `string` | n/a | yes |
| <a name="input_delete_default_resources_lambda_kms_encryption"></a> [delete\_default\_resources\_lambda\_kms\_encryption](#input\_delete\_default\_resources\_lambda\_kms\_encryption) | Conditionally encrypt the Delete Default Resources Lambda logs with KMS | `bool` | n/a | yes |
| <a name="input_delete_default_resources_log_retention"></a> [delete\_default\_resources\_log\_retention](#input\_delete\_default\_resources\_log\_retention) | Log retention for the Delete Default Resources Lambda | `number` | n/a | yes |
| <a name="input_enable_cloudtrail"></a> [enable\_cloudtrail](#input\_enable\_cloudtrail) | Enable Cloudtrail | `bool` | n/a | yes |
| <a name="input_enable_cloudwatch_opsgenie_alerts"></a> [enable\_cloudwatch\_opsgenie\_alerts](#input\_enable\_cloudwatch\_opsgenie\_alerts) | Enable CloudWatch Opsgenie alerts. This creates an SNS topic to which alerts and pipelines can send messages, which are then sent to the Opsgenie SNS endpoint. | `bool` | n/a | yes |
| <a name="input_enable_cloudwatch_slack_alerts"></a> [enable\_cloudwatch\_slack\_alerts](#input\_enable\_cloudwatch\_slack\_alerts) | Enable CloudWatch Slack alerts. This creates an SNS topic to which alerts and pipelines can send messages, which are then picked up by a Lambda function that forwards them to a Slack webhook. | `bool` | n/a | yes |
| <a name="input_enable_datadog_aws_integration"></a> [enable\_datadog\_aws\_integration](#input\_enable\_datadog\_aws\_integration) | Conditionally create the datadog AWS integration role (https://docs.datadoghq.com/integrations/guide/aws-terraform-setup/) and configure the datadog integration | `bool` | n/a | yes |
| <a name="input_enable_delete_default_resources"></a> [enable\_delete\_default\_resources](#input\_enable\_delete\_default\_resources) | Creates a Lambda function which deletes all default VPCs and resources within them. This only needs to be ran once, either through the AWS console or via the AWS CLI | `bool` | n/a | yes |
| <a name="input_enable_route53_root_hosted_zone"></a> [enable\_route53\_root\_hosted\_zone](#input\_enable\_route53\_root\_hosted\_zone) | Conditionally create Route53 hosted zone, which will contain the DNS records for resources launched within the account. | `bool` | n/a | yes |
| <a name="input_enable_s3_tfvars"></a> [enable\_s3\_tfvars](#input\_enable\_s3\_tfvars) | enable\_s3\_tfvars | `bool` | n/a | yes |
| <a name="input_enable_ssm_dhmc"></a> [enable\_ssm\_dhmc](#input\_enable\_ssm\_dhmc) | Enables SSM Default Host Management Configuration | `bool` | n/a | yes |
| <a name="input_logging_bucket_retention"></a> [logging\_bucket\_retention](#input\_logging\_bucket\_retention) | Logging bucket retention in days. Set to 0 to keep all logs. | `number` | n/a | yes |
| <a name="input_openid_connect_providers"></a> [openid\_connect\_providers](#input\_openid\_connect\_providers) | Conditionally create OpenID connect providers. The thumbprints will be automatically generated | <pre>map(object({<br/>    host           = string<br/>    client_id_list = list(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name to be used as a prefix for all resources | `string` | n/a | yes |
| <a name="input_route53_root_hosted_zone_domain_name"></a> [route53\_root\_hosted\_zone\_domain\_name](#input\_route53\_root\_hosted\_zone\_domain\_name) | Route53 root hosted zone domain name | `string` | n/a | yes |
| <a name="input_tfvars_s3_enable_s3_bucket_logging"></a> [tfvars\_s3\_enable\_s3\_bucket\_logging](#input\_tfvars\_s3\_enable\_s3\_bucket\_logging) | Enable S3 bucket logging on the tfvars S3 bucket | `bool` | `true` | no |
| <a name="input_tfvars_s3_logging_bucket_retention"></a> [tfvars\_s3\_logging\_bucket\_retention](#input\_tfvars\_s3\_logging\_bucket\_retention) | tfvars S3 Logging bucket retention in days. Set to 0 to keep all logs. | `number` | `30` | no |
| <a name="input_tfvars_s3_tfvars_files"></a> [tfvars\_s3\_tfvars\_files](#input\_tfvars\_s3\_tfvars\_files) | Map of objects containing tfvar file paths | <pre>map(<br/>    object({<br/>      path = string<br/>      key  = optional(string, "")<br/>      }<br/>  ))</pre> | `{}` | no |
| <a name="input_tfvars_s3_tfvars_restrict_access_user_ids"></a> [tfvars\_s3\_tfvars\_restrict\_access\_user\_ids](#input\_tfvars\_s3\_tfvars\_restrict\_access\_user\_ids) | List of AWS User IDs that require access to the tfvars S3 bucket. If left empty, all users within the AWS account will have access | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
