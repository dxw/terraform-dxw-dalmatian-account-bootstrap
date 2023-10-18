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
}
