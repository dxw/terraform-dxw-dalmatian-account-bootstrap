{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "backup:ListRecoveryPointsByBackupVault",
                "bcm-data-exports:GetExport",
                "bcm-data-exports:ListExports",
                "cassandra:Select",
                "cur:DescribeReportDefinitions",
                "ec2:GetSnapshotBlockPublicAccessState",
                "glacier:GetVaultNotifications",
                "glue:ListRegistries",
                "lightsail:GetInstancePortStates",
                "savingsplans:DescribeSavingsPlanRates",
                "savingsplans:DescribeSavingsPlans",
                "timestream:DescribeEndpoints",
                "waf-regional:ListRuleGroups",
                "waf-regional:ListRules",
                "waf:ListRuleGroups",
                "waf:ListRules",
                "wafv2:GetIPSet",
                "wafv2:GetRegexPatternSet",
                "wafv2:GetRuleGroup"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
