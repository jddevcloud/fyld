resource "aws_waf_web_acl" "waf_acl" {
  count       = var.waf_enabled ? 1 : 0
  name        = "${var.project_name}-${replace(var.env, "-", "")}-maestro-waf"
  metric_name = "${title(var.project_name)}${title(replace(var.env, "-", ""))}MaestroWaf"

  default_action {
    type = "ALLOW"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 1
    rule_id  = aws_waf_rate_based_rule.rate_limit[0].id
    type     = "RATE_BASED"
  }
  depends_on = [aws_waf_rate_based_rule.rate_limit]
}

resource "aws_waf_rate_based_rule" "rate_limit" {
  count       = var.waf_enabled ? 1 : 0
  name        = "${var.project_name}-${replace(var.env, "-", "")}-maestro-rate-limit"
  metric_name = "${title(var.project_name)}${title(replace(var.env, "-", ""))}MaestroRateLimit"

  rate_key   = "IP"
  rate_limit = var.waf_rate_limit
}
