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
        "kms:GenerateDataKey*"
      ],
      "Resource": "*",
      "Condition": {
        "Condition": {
          "StringEquals": {
            "aws:SourceArn": "${cloudtrail_arn}"
          },
          "StringLike": {
            "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${aws_account_id}:trail/*"
          }
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ${services}
      },
      "Action": "kms:Decrypt",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${aws_account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ${services}
      },
      "Action": "kms:DescribeKey",
      "Resource": "arn:aws:kms:${aws_region}:${aws_account_id}:key/*",
      "Condition": {
        "StringEquals": {
            "aws:SourceArn": "${cloudtrail_arn}"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.region.amazonaws.com"
      },
      "Action": [
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ],
      "Resource": "*",
      "Condition": {
        "ArnEquals": {
          "kms:EncryptionContext:aws:logs:arn": "${log_group_arn}"
        }
      }
    }
  ]
}
