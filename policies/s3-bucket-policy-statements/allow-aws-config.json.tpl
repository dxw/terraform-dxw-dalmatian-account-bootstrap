{
  "Principal": {
    "Service": "config.amazonaws.com"
  },
  "Action": [
    "s3:GetBucketAcl"
  ],
  "Effect": "Allow",
  "Resource": "${log_bucket_arn}",
  "Condition": {
    "StringEquals": {
      "aws:SourceAccount": "${aws_account_id}"
    }
  }
},
{
  "Principal": {
    "Service": "config.amazonaws.com"
  },
  "Action": [
    "s3:PutOject"
  ],
  "Effect": "Allow",
  "Resource": "${log_bucket_arn}/AWSLogs/${aws_account_id}/*",
  "Condition": {
    "StringEquals": {
      "aws:SourceAccount": ${aws_account}
    }
  }
}
