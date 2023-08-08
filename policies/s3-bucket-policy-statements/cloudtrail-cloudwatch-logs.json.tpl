{
  "Effect": "Allow",
  "Principal": {
    "Service": "cloudtrail.amazonaws.com"
  },
  "Action": "s3:GetBucketAcl",
  "Resource": "${bucket_arn}",
  "Condition": {
    "StringEquals": {
      "aws:SourceArn": "${cloudtrail_arn}"
    }
  }
},
{
  "Effect": "Allow",
  "Principal": {
    "Service": "cloudtrail.amazonaws.com"
  },
  "Action": "s3:PutObject",
  "Resource": "${bucket_arn}/%{if logs_prefix != ""}${logs_prefix}/%{endif}AWSLogs/${account_id}/*",
  "Condition": {
    "StringEquals": {
      "s3:x-amz-acl": "bucket-owner-full-control",
      "aws:SourceArn": "${cloudtrail_arn}"
    }
  }
}
