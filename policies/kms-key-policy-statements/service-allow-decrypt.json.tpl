{
  "Effect": "Allow",
  "Principal": {
    "Service": ${services}
  },
  "Action": "kms:Decrypt",
  "Resource": "*"
}
