//--------------------------------------------------------------------
// Modules
module "cinegy_base" {
  source  = "app.terraform.io/cinegy/cinegy-base/aws"
  version = "0.0.10"

  app_name = "air-test"
  aws_region = "eu-west-1"
  customer_tag = "CINEGY"
  environment_name = "dev"
  aws_secrets_privatekey_arn = "arn:aws:secretsmanager:eu-west-1:564731076164:secret:terraform-cinegycentral-deployment/dev/privatekey.pem-GVW7XA"
  domain_name = var.domain_name
  domain_admin_password = var.domain_admin_password
}

module "cinegy-base-winvm" {
  source  = "app.terraform.io/cinegy/cinegy-base-winvm/aws"
  version = "0.0.1"
}
