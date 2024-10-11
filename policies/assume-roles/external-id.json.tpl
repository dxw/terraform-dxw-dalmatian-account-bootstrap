{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": ${iam_arns}
      },
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "${external_id}"
        }
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
