# mark this installation as being hosted by Terraform Cloud in the Cinegy org
terraform {
  backend "remote" {
    organization = "cinegy"

    workspaces {
      name = "CinegyVPC"
    }
  }
}

# define repeatedly re-used variables here
locals {
  app_name = "air-test"
  aws_region = "eu-west-1"
  customer_tag = "IABM"
  environment_name = "dev"
}

# define the specific providers, including providers required to pass into modules
provider "aws" {
  region  = local.aws_region
  version = "~> 2.70"
}

provider "tls" {
  version = "~> 2.2"
}

provider "template" {
  version = "~> 2.1.2"
}


//--------------------------------------------------------------------
// Modules
module "cinegy_base" {
  source  = "app.terraform.io/cinegy/cinegy-base/aws"
  app_name = local.app_name
  aws_region = local.aws_region
  customer_tag = local.customer_tag
  environment_name = local.environment_name
  version = "0.0.11"  

  aws_secrets_privatekey_arn = "arn:aws:secretsmanager:eu-west-1:564731076164:secret:terraform-cinegycentral-deployment/dev/privatekey.pem-GVW7XA"
  domain_name = var.domain_name
  domain_admin_password = var.domain_admin_password
}

module "sysadmin-vm" {
  source  = "app.terraform.io/cinegy/cinegy-base-winvm/aws"
  app_name = local.app_name
  aws_region = local.aws_region
  customer_tag = local.customer_tag
  environment_name = local.environment_name  
  instance_profile_name = module.cinegy_base.instance_profile_default_ec2_instance_name
  vpc_id = module.cinegy_base.main_vpc
  directory_service_default_doc_name = module.cinegy_base.directory_service_default_doc_name
  version = "0.0.10"

  host_name_prefix = "SYSADMIN1A"
  host_description = "DEV-Sysadmin Terminal (SYSADMIN) 1A"
  aws_subnet_tier = "Public"

  security_groups = [
    module.cinegy_base.remote_access_security_group,
    module.cinegy_base.remote_access_udp_6000_6100
  ]

}

module "cinegy-air" {
  source  = "app.terraform.io/cinegy/cinegy-base-winvm/aws"
  app_name = local.app_name
  aws_region = local.aws_region
  customer_tag = local.customer_tag
  environment_name = local.environment_name
  instance_profile_name = module.cinegy_base.instance_profile_default_ec2_instance_name
  vpc_id = module.cinegy_base.main_vpc
  directory_service_default_doc_name = module.cinegy_base.directory_service_default_doc_name
  version = "0.0.10"

  count = 2

  ami_name = "Marketplace_Air_v14*"
  
  host_name_prefix = "AIR${count.index+1}A"
  host_description = "DEV-Playout (AIR) ${count.index+1}A"
  aws_subnet_tier = "Public"

  security_groups = [
    module.cinegy_base.remote_access_security_group,
    module.cinegy_base.remote_access_udp_6000_6100
  ]
}