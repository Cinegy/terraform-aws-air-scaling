//--------------------------------------------------------------------
// Modules
module "cinegy_base" {
  source  = "app.terraform.io/cinegy/cinegy-base/aws"
  version = "0.0.10"

  app_name = "air-test"
  aws_region = "eu-west-1"
  customer_tag = "IABM"
  environment_name = "dev"
  aws_secrets_privatekey_arn = "arn:aws:secretsmanager:eu-west-1:564731076164:secret:terraform-cinegycentral-deployment/dev/privatekey.pem-GVW7XA"
  domain_name = var.domain_name
  domain_admin_password = var.domain_admin_password
}

module "cinegy-base-winvm" {
  source  = "app.terraform.io/cinegy/cinegy-base-winvm/aws"
  version = "0.0.5"

  app_name = "air-test"
  aws_region = "eu-west-1"
  customer_tag = "IABM"
  environment_name = "dev"

  instance_profile_name = module.cinegy_base.instance_profile_default_ec2_instance_name
  vpc_id = module.cinegy_base.main_vpc
  directory_service_default_doc_name = module.cinegy_base.directory_service_default_doc_name
}

module "sysadmin-vm" {
  source  = "app.terraform.io/cinegy/cinegy-base-winvm/aws"
  version = "0.0.5"

  app_name = "air-test"
  aws_region = "eu-west-1"
  customer_tag = "IABM"
  environment_name = "dev"
  host_name_prefix = "SYSADMIN1A"
  aws_subnet_tier = "Public"

  instance_profile_name = module.cinegy_base.instance_profile_default_ec2_instance_name
  vpc_id = module.cinegy_base.main_vpc
  directory_service_default_doc_name = module.cinegy_base.directory_service_default_doc_name
}

