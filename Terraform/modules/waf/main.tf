################################
# WAFv2 WEB ACL
################################
resource "aws_wafv2_web_acl" "waf_web_acl" {
  name        = var.web_acl_name
  scope       = var.scope
  description = "WAF for ${var.web_acl_name}"

  default_action {
    allow {}
  }

  ################################
  # AWS Managed Common Rules
  ################################
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSCommonRules"
      sampled_requests_enabled   = true
    }
  }

  ################################
  # SQL Injection Protection
  ################################
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLiRules"
      sampled_requests_enabled   = true
    }
  }


  ################################
  # Malicious IP Reputation
  ################################
  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 25

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IPReputation"
      sampled_requests_enabled   = true
    }
  }

  ################################
  # Visibility
  ################################
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.web_acl_name
    sampled_requests_enabled   = true
  }

}

################################
# ASSOCIATE WAF WITH ALB
################################
resource "aws_wafv2_web_acl_association" "alb_assoc" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.waf_web_acl.arn
}

