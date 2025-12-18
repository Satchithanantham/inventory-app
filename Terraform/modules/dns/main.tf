resource "aws_route53_record" "records" {
  for_each = var.records

  zone_id = var.hosted_zone_id
  name    = "${each.key}.cloudcopdemo.prod.hidcloud.com"
  type    = "A"

  alias {
    name                   = each.value
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
