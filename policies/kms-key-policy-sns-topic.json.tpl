{
  "Version": "2012-10-17",
  "Id": "key-service-permissions",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ${services}
      },
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:EncryptionContext:aws:sns:topicArn": "${sns_topic_arn}"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${aws_account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
