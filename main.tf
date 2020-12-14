# mark this installation as being hosted by Terraform Cloud in the Cinegy org
terraform {
  backend "remote" {
    organization = "cinegy"

    workspaces {
      name = "terraform-aws-air-testing"
    }
  }
}

# define repeatedly re-used variables here
locals {
  app_name = "air-scaletest"
  aws_region = "eu-west-1"
  customer_tag = "cinegy"
  environment_name = "demo"
  directory_type = "SimpleAD"
  directory_edition = null
  route53_zone_name = "qa.terraform.cinegy.net"
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

# install the base infrastructure required to support other module elements
module "cinegy_base" {
  
  source  = "app.terraform.io/cinegy/cinegy-base/aws"
  version = "0.0.13"

  app_name = local.app_name
  aws_region = local.aws_region
  customer_tag = local.customer_tag
  environment_name = local.environment_name

  aws_secrets_privatekey_arn = "arn:aws:secretsmanager:eu-west-1:564731076164:secret:cinegy-qa/privatekey.pem-ChNfQs"
  domain_name = var.domain_name
  domain_admin_password = var.domain_admin_password
  directory_type = local.directory_type
  directory_edition = local.directory_edition
}

# create VMs to run Air workloads
module "cinegy-air" {
  source  = "app.terraform.io/cinegy/cinegy-base-winvm/aws"
  version = "0.0.28"

  count = var.air_vm_count

  app_name          = local.app_name
  aws_region        = local.aws_region
  customer_tag      = local.customer_tag
  environment_name  = local.environment_name  
  instance_profile  = module.cinegy_base.instance_profile_default_ec2_instance_name
  vpc_id            = module.cinegy_base.main_vpc  
  ad_join_doc_name  = module.cinegy_base.ad_join_doc_name
  join_ad           = true
  #tenancy           = "host" 

  ami_name          = "Windows_Server-2019-English-Full-Radeon*"
  host_name_prefix  = "AIR${count.index+1}A"
  host_description  = "${upper(local.environment_name)}-Playout (AIR) ${count.index+1}A"
  instance_subnet   = module.cinegy_base.public_subnets.a
  instance_type     = "g4ad.4xlarge"
  create_external_dns_reference = true
  route53_zone_name = local.route53_zone_name
  attach_data_volume = false

  security_groups = [
    module.cinegy_base.remote_access_security_group,
    module.cinegy_base.remote_access_udp_6000_6100,
    module.cinegy_base.remote_access_playout_engine_rest_5521_5600
  ]

  user_data_script_extension = <<EOF
  
  Install-CinegyPowershellModules
  Install-DefaultPackages
  Install-Product -PackageName Cinegy-License-Service-Trunk -VersionTag dev
  Install-Product -PackageName Cinegy-Air-v15.x -VersionTag dev
  Install-Product -PackageName Thirdparty-MetricBeat-NVGPU-v6.x -VersionTag dev
  Install-Product -PackageName Thirdparty-AWSCLI-v2.x -VersionTag prod
  
  Get-AwsLicense -UseTaggedHostname $true
  Set-LicenseServerSettings -AllowSharing $true -ServiceUrl "https://api.central.cinegy.com/awsmrkt/v1/license/renew?serialId="
  
  #fix Air Control DLL registry failure
  Start-Process -FilePath "C:\Program Files\Cinegy\Cinegy Air PRO (x64) 15.0.0\CinegyAirServerEx.exe" -ArgumentList "/regserver"

  #format scratch disk
  Get-Disk | Where-Object partitionstyle -eq 'raw' | 
  Initialize-Disk -PartitionStyle MBR -PassThru | 
  New-Partition -AssignDriveLetter -UseMaximumSize | 
  Format-Volume -FileSystem NTFS -NewFileSystemLabel "DATA" -Confirm:$false 

  #download test content
  $bucket = 'cinegyqa-testcontent'

  $files = Get-S3Object -BucketName $bucket -KeyPrefix 'scripts'
  foreach($file in $files) {
    Copy-S3Object -SourceBucket $bucket -SourceKey $($file.Key) -LocalFolder 'd:\'
  }

  [System.Environment]::SetEnvironmentVariable('ENGINE_COUNT', ${var.engine_count}, [System.EnvironmentVariableTarget]::Machine)
	
  # $trigger = New-JobTrigger -AtStartup -RandomDelay 00:00:45
  # Register-ScheduledJob -Trigger $trigger -FilePath D:\scripts\run-test-cycle.ps1 -Name TestCycle

  Uninstall-WindowsFeature -Name Windows-Defender
  Set-Service wuauserv -StartupType Disabled

  RenameHost

  # #install NV drivers last, since they can trigger a reboot
  # Install-Product -PackageName Thirdparty-AirNvidiaAwsDrivers-v14.x -VersionTag dev
EOF
}
