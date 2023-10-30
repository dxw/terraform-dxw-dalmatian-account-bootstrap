locals {
  project_name      = var.project_name
  project_name_hash = format("%.6s", sha1(local.project_name))
  aws_region        = var.aws_region
  aws_account_id    = data.aws_caller_identity.current.account_id

  enable_s3_tfvars                          = var.enable_s3_tfvars
  tfvars_s3_enable_s3_bucket_logging        = var.tfvars_s3_enable_s3_bucket_logging
  tfvars_s3_logging_bucket_retention        = var.tfvars_s3_logging_bucket_retention
  tfvars_s3_tfvars_files                    = var.tfvars_s3_tfvars_files
  tfvars_s3_tfvars_restrict_access_user_ids = var.tfvars_s3_tfvars_restrict_access_user_ids

  enable_cloudtrail                          = var.enable_cloudtrail
  cloudtrail_kms_encryption                  = var.cloudtrail_kms_encryption
  cloudtrail_log_retention                   = var.cloudtrail_log_retention
  cloudtrail_log_prefix                      = var.cloudtrail_log_prefix
  cloudtrail_s3_access_logs                  = var.cloudtrail_s3_access_logs && local.enable_cloudtrail
  cloudtrail_athena_glue_tables              = local.enable_cloudtrail && var.cloudtrail_athena_glue_tables
  cloudtrail_athena_s3_output_retention      = var.cloudtrail_athena_s3_output_retention
  cloudtrail_athena_s3_output_kms_encryption = local.cloudtrail_athena_glue_tables && var.cloudtrail_athena_s3_output_kms_encryption
  cloudtrail_glue_table_columns = {
    eventversion        = "string",
    useridentity        = "struct<type:string,principalId:string,arn:string,accountId:string,invokedBy:string,accessKeyId:string,userName:string,sessionContext:struct<attributes:struct<mfaAuthenticated:string,creationDate:string>,sessionIssuer:struct<type:string,principalId:string,arn:string,accountId:string,username:string>,ec2RoleDelivery:string,webIdFederationData:map<string,string>>>",
    eventtime           = "string",
    eventsource         = "string",
    eventname           = "string",
    awsregion           = "string",
    sourceipaddress     = "string",
    useragent           = "string",
    errorcode           = "string",
    errormessage        = "string",
    requestparameters   = "string",
    responseelements    = "string",
    additionaleventdata = "string",
    requestid           = "string",
    eventid             = "string",
    resources           = "array<struct<arn:string,accountId:string,type:string>>",
    eventtype           = "string",
    apiversion          = "string",
    readonly            = "string",
    recipientaccountid  = "string",
    serviceeventdetails = "string",
    sharedeventid       = "string",
    vpcendpointid       = "string",
    tlsdetails          = "struct<tlsVersion:string,cipherSuite:string,clientProvidedHostHeader:string>"
  }

  enable_cloudwatch_slack_alerts         = var.enable_cloudwatch_slack_alerts
  cloudwatch_slack_alerts_kms_encryption = var.cloudwatch_slack_alerts_kms_encryption && local.enable_cloudwatch_slack_alerts
  cloudwatch_slack_alerts_hook_url       = var.cloudwatch_slack_alerts_hook_url
  cloudwatch_slack_alerts_channel        = var.cloudwatch_slack_alerts_channel
  cloudwatch_slack_alerts_log_retention  = var.cloudwatch_slack_alerts_log_retention

  enable_cloudwatch_opsgenie_alerts             = var.enable_cloudwatch_opsgenie_alerts
  cloudwatch_opsgenie_alerts_sns_kms_encryption = var.cloudwatch_opsgenie_alerts_sns_kms_encryption && local.enable_cloudwatch_opsgenie_alerts
  cloudwatch_opsgenie_alerts_sns_endpoint       = var.cloudwatch_opsgenie_alerts_sns_endpoint

  codestar_connections = var.codestar_connections

  enable_logs_bucket       = local.cloudtrail_s3_access_logs || local.cloudtrail_athena_glue_tables
  logging_bucket_retention = var.logging_bucket_retention
  logs_bucket_source_arns = concat(
    local.cloudtrail_s3_access_logs ? [aws_s3_bucket.cloudtrail[0].arn] : [],
    local.cloudtrail_athena_glue_tables ? [aws_s3_bucket.athena_cloudtrail_output[0].arn] : [],
  )

  default_tags = {
    Project = local.project_name,
  }
}
