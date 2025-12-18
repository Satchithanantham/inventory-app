 terraform {
  backend "s3" {
    bucket         = "satchi-tf-state-inventory-app"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "Satchi-tf-state-locks"
    use_lockfile = true
  }
}
