resource "aws_athena_named_query" "cloudtrail" {
  count = local.cloudtrail_athena_glue_tables ? 1 : 0

  name      = "${local.project_name} CloudTrail select recent"
  workgroup = aws_athena_workgroup.cloudtrail[0].id
  database  = aws_glue_catalog_database.cloudtrail[0].name
  query     = "SELECT * FROM ${aws_glue_catalog_table.cloudtrail[0].name} limit 100;"
}
