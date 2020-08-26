//--------------------------------------------------------------------
// Modules
module "cinegy_base" {
  source  = "app.terraform.io/cinegy/cinegy-base/aws"
  version = "0.0.5"

  app_name = "air-test"
  aws_region = "eu-west-1"
  customer_tag = "CINEGY"
  environment_name = "dev"
  domain_admin_password = var.domain_admin_password
}