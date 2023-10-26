{
  "Effect": "Allow",
  "Principal": {
    "Service": ${services}
  },
  "Action": "kms:DescribeKey",
  "Resource": "${key_arn}",
  "Condition": {
    "StringEquals": {
        "aws:SourceArn": "${source_arn}"
    }
  }
}
