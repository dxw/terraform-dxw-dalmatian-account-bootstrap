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
        "AWS": "arn:aws:iam::511700466171:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    }%{ if additional_principle_allow != "[]" },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": ${additional_principle_allow}
      },
      "Action": "kms:*",
      "Resource": "*"
    }
    %{~ endif }
  ]
}
