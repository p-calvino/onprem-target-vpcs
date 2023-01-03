# Terraform local variables
locals {
  project_name        = "CAPCI-Group4"
  environment         = "Development"
  challenge           = "migration-rehost"
  region              = "eu-central-1"
  vpc_name            = "Virtual-On-Prem-VPC"
  ubuntu_ami_name     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"
  ubuntu_ami_owner    = "099720109477"
  ec2_type_web        = "t3.medium"
  ec2_type_db         = "m5.large"
  keypair_name        = "rehost-migration-key"
  webserver_sg_name   = "OnPrem-Webserver-SG"
  database_sg_name    = "OnPrem-Database-SG"
  public_cidr         = "172.16.10.0/24"
  private_cidr        = "172.16.20.0/24"
  vpc_cidr            = "172.16.0.0/16"

  tags = {
    ProjectName = local.project_name
    Environment = local.environment
    Challenge   = local.challenge
  }
}
