output "resource_map" {
  description = "Simplified map of resources and their dependencies, associations and attachments"
  value = {
    route53_zone_root = {
      _description = "Route53 zone for the root domain zone that can be used for other resources"
      enabled      = local.enable_route53_root_hosted_zone
      name         = local.enable_route53_root_hosted_zone ? aws_route53_zone.root[0].name : null
    }
    default_host_configurtation_management = {
      _description = "Default Host Configuration Management settings"
      enabled      = local.enable_ssm_dhmc
      role_name    = local.enable_ssm_dhmc ? aws_iam_role.ssm_dhmc[0].name : null
    }
    codestar_connections = {
      _description = "CodeStar connection ARNs"
      arns = {
        for connection in local.codestar_connections : connection.value => aws_codestarconnections_connection.connections[connection.value].arn
      }
    }
    alerts = {
      _descrpition = "Slack and Opsgenie SNS endpoints which accepts CloudWatch alerts"
      slack = {
        enabled = local.enable_cloudwatch_slack_alerts
        sns_arn = local.enable_cloudwatch_slack_alerts ? aws_sns_topic.cloudwatch_slack_alerts[0].arn : null
        lambda = {
          function_name = local.enable_cloudwatch_slack_alerts ? aws_lambda_function.cloudwatch_slack_alerts[0].function_name : null
          role          = local.enable_cloudwatch_slack_alerts ? aws_iam_role.cloudwatch_slack_alerts_lambda[0].name : null
          log_retention = local.enable_cloudwatch_slack_alerts ? local.cloudwatch_slack_alerts_log_retention : null
        }
      }
      opsgenie = {
        enabled = local.enable_cloudwatch_opsgenie_alerts
        sns_arn = local.enable_cloudwatch_opsgenie_alerts ? aws_sns_topic.cloudwatch_opsgenie_alerts[0].arn : null
        sns_kms_key = {
          arn   = local.cloudwatch_opsgenie_alerts_sns_kms_encryption ? aws_kms_key.cloudwatch_opsgenie_alerts_sns[0].arn : null
          alias = local.cloudwatch_opsgenie_alerts_sns_kms_encryption ? aws_kms_alias.cloudwatch_opsgenie_alerts_sns[0].name : null
        }
        sns_us_east_1_arn = local.enable_cloudwatch_opsgenie_alerts ? aws_sns_topic.cloudwatch_opsgenie_alerts_us_east_1[0].arn : null
        sns_us_east_1_kms_key = {
          arn   = local.cloudwatch_opsgenie_alerts_sns_kms_encryption ? aws_kms_key.cloudwatch_opsgenie_alerts_sns_us_east_1[0].arn : null
          alias = local.cloudwatch_opsgenie_alerts_sns_kms_encryption ? aws_kms_alias.cloudwatch_opsgenie_alerts_sns_us_east_1[0].name : null
        }
      }
    }
    delete_default_resources = {
      _descrpition = "Parameters for the Lambda created to delete default resources"
      enabled      = local.enable_delete_default_resources
      kms_key = {
        arn   = local.delete_default_resources_lambda_kms_encryption ? aws_kms_key.delete_default_resources_lambda[0].arn : null
        alias = local.delete_default_resources_lambda_kms_encryption ? aws_kms_alias.delete_default_resources_lambda[0].name : null
      }
      lambda = {
        function_name = local.enable_delete_default_resources ? aws_lambda_function.delete_default_resources[0].function_name : null
        role          = local.enable_delete_default_resources ? aws_iam_role.delete_default_resources_lambda[0].name : null
        log_retention = local.enable_delete_default_resources ? local.delete_default_resources_log_retention : null
      }
    }
    cloudtrail = {
      _description = "Cloudtrail and associated CloudWatch / S3 bucket / Athena parameters"
      enabled      = local.enable_cloudtrail
      trail = {
        name = local.enable_cloudtrail ? aws_cloudtrail.cloudtrail[0].name : null
        role = local.enable_cloudtrail ? aws_iam_role.cloudtrail_cloudwatch_logs[0].name : null
      }
      s3_bucket_name = local.enable_cloudtrail ? aws_s3_bucket.cloudtrail[0].bucket : null
      cloudwatch = {
        log_group_name      = local.enable_cloudtrail ? aws_cloudwatch_log_group.cloudtrail[0].name : null
        log_group_retention = local.enable_cloudtrail ? local.cloudtrail_log_retention : null
      }
      kms_key = {
        arn   = local.cloudtrail_kms_encryption ? aws_kms_key.cloudtrail_cloudwatch_logs[0].arn : null
        alias = local.cloudtrail_kms_encryption ? aws_kms_alias.cloudtrail_cloudwatch_logs[0].name : null
      }
      athena = {
        enabled                = local.cloudtrail_athena_glue_tables
        workgroup_name         = local.cloudtrail_athena_glue_tables ? aws_athena_workgroup.cloudtrail[0].name : null
        result_output_location = local.cloudtrail_athena_glue_tables ? aws_athena_workgroup.cloudtrail[0].configuration[0].result_configuration[0].output_location : null
      }
    }
    tfvars_s3 = {
      _description                          = "S3 bucket where tfvars are stored"
      enabled                               = local.enable_s3_tfvars
      tfvars_bucket_name                    = local.enable_s3_tfvars ? module.aws_tfvars_s3[0].aws_s3_bucket_tfvars.bucket : null
      tfvars_bucket_restrictaccess_user_ids = local.enable_s3_tfvars && length(local.tfvars_s3_tfvars_restrict_access_user_ids) > 0 ? local.tfvars_s3_tfvars_restrict_access_user_ids : null
      logging_enabled                       = local.enable_s3_tfvars ? local.tfvars_s3_enable_s3_bucket_logging : null
      logging_bucket_name                   = local.enable_s3_tfvars && local.tfvars_s3_enable_s3_bucket_logging ? module.aws_tfvars_s3[0].aws_s3_bucket_logs.bucket : null
      loggin_bucket_retention               = local.enable_s3_tfvars && local.tfvars_s3_enable_s3_bucket_logging ? local.tfvars_s3_logging_bucket_retention : null
    }
  }
}
