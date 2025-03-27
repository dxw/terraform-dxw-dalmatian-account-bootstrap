{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "${bucket_arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": [
        %{ if bucket_arn != "*" ~}
        "${bucket_arn}/*"
        %{ else ~}
        "*"
        %{ endif ~}
      ]
    }
  ]
}
