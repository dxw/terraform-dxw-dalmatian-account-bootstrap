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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.9.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_tfvars_s3"></a> [aws\_tfvars\_s3](#module\_aws\_tfvars\_s3) | github.com/dxw/terraform-aws-tfvars-s3 | v0.1.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region in which to launch resources | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name to be used as a prefix for all resources | `string` | n/a | yes |
| <a name="input_tfvars_s3_enable_s3_bucket_logging"></a> [tfvars\_s3\_enable\_s3\_bucket\_logging](#input\_tfvars\_s3\_enable\_s3\_bucket\_logging) | Enable S3 bucket logging on the tfvars S3 bucket | `bool` | n/a | yes |
| <a name="input_tfvars_s3_logging_bucket_retention"></a> [tfvars\_s3\_logging\_bucket\_retention](#input\_tfvars\_s3\_logging\_bucket\_retention) | tfvars S3 Logging bucket retention in days. Set to 0 to keep all logs. | `number` | n/a | yes |
| <a name="input_tfvars_s3_tfvars_files"></a> [tfvars\_s3\_tfvars\_files](#input\_tfvars\_s3\_tfvars\_files) | Map of objects containing tfvar file paths | <pre>map(<br>    object({<br>      path = string<br>      }<br>  ))</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
