{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codepipeline:GetPipelineExecution"
      ],
      "Resource": "arn:aws:codepipeline:*:${account_id}:*"
    }
  ]
}
