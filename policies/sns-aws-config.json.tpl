{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Action": [
        "SNS:Publish"
      ],
      "Resource": "${sns_arn}"
    }
  ]
}
