provider "aws" {
  alias  = "north_virginia_region"
  region = "us-east-1"
}

resource "aws_wafv2_web_acl" "this" {
  provider = aws.north_virginia_region

  name        = "${var.stage}_portal_cloudfront_waf"
  description = "WAF for ${var.stage} cloudfront distributions"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 0

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
      metric_name                = "portal_AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }

  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 1

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
      metric_name                = "portal_AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }

    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "portal_AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "portal_cloudfront_waf"
    sampled_requests_enabled   = true
  }

  tags = {
    Name        = join("-", [var.stage, var.project, var.module, "portal-cloudfront-waf"])
    Exposure    = "Private"
    Description = "WAF for ${var.stage} cloudfront distributions"
  }
}
