{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream"
      ],
      "Resource": [
        "${cloudwatch_log_group_arn}:log-stream:${account_id}_CloudTrail_${region}*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:PutLogEvents"
      ],
      "Resource": [
        "${cloudwatch_log_group_arn}:log-stream:${account_id}_CloudTrail_${region}*"
      ]
    }
  ]
}
