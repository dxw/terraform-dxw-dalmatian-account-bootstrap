{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "allow-sns-source-owner",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "SNS:GetTopicAttributes",
        "SNS:SetTopicAttributes",
        "SNS:AddPermission",
        "SNS:RemovePermission",
        "SNS:DeleteTopic",
        "SNS:Subscribe",
        "SNS:ListSubscriptionsByTopic",
        "SNS:Publish",
        "SNS:Receive"
      ],
      "Resource": "${sns_arn}",
      "Condition": {
        "StringEquals": {
          "AWS:SourceOwner": "${aws_account_id}"
        }
      }
    },
    {
      "Sid": "allow-sns-events-publish",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sns:Publish",
      "Resource": "${sns_arn}"
    }
  ]
}
