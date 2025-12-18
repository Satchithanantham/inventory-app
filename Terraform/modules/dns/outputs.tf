output "records" {
  description = "Map of Route53 records created by this module"
  value = {
    for k, v in aws_route53_record.records :
    k => {
      name    = v.name
      zone_id = v.zone_id
      type    = v.type
    }
  }
}

output "record_names" {
  description = "List of all Route53 record names created"
  value       = [for r in aws_route53_record.records : r.name]
}

output "record_fqdns" {
  description = "Fully qualified domain names of Route53 records"
  value       = [for r in aws_route53_record.records : r.fqdn]
}
