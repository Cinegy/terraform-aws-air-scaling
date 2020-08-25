//--------------------------------------------------------------------
// Modules
module "cinegy_base" {
  source  = "app.terraform.io/cinegy/cinegy-base/aws"
  version = "0.0.2"
  region = "eu-west-1"

  app_name = "air-test"
  aws_region = "eu-west-1"
  customer_tag = "CINEGY"
  environment_name = "dev"
}