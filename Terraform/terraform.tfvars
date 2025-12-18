
aws_region = "us-east-1"
account_id = "529088274428"
app_name   = "inventory"

vpc_id = "vpc-0e751b6e61caae7c4"

public_subnet_ids = [
  "subnet-0acbe5c0a85ae3036",
  "subnet-0b7416afa26f4a297",
]

private_subnet_ids = [
  "subnet-0d4d3847f381abf59",
  "subnet-0c8987bb821da513d",
]

# Start with HTTP; enable later when ACM cert is ready
enable_https    = true
certificate_arn = "arn:aws:acm:us-east-1:529088274428:certificate/d546ff26-947d-4e26-a001-ef5fd3c81709"

container_port = 5000
cpu            = 256
memory         = 512
desired_count  = 1
image_tag      = "latest"

ecr_repositories = ["backend", "frontend"]
environment = {
  PORT = "5000"
  # DB_HOST = "inventory.xxxxx.us-east-1.rds.amazonaws.com"
  # DB_NAME = "inventory"
}
# Optional DNS (fill when you have hosted zone & want a friendly name)
hosted_zone_id         = "Z0498892K4FC3M48S0VV"
api_domain_name        = "inventory.api.cloudcopdemo.prod.hidcloud.com"
db_password_secret_arn = "arn:aws:secretsmanager:us-east-1:529088274428:secret:inventory-db-password-yLZF96"
alert_email            = "satchithanantham.balamurugan@hidglobal.com"

