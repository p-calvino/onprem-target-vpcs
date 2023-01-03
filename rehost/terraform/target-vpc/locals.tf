# Terraform local variables
# Terraform local variables
locals {
  project_name               = "CAPCI-Group4"
  environment                = "Development"
  challenge                  = "migration-rehost"
  target_vpc_name            = "VPC_cloud"
  vpc_cidr                   = "10.0.16.0/20"
  public_cidr                = "10.0.16.0/24"
  private_application_server = "10.0.24.0/25"
  private_db_servers_cidr    = "10.0.24.128/25"
  private_mgn                = "10.0.25.0/25"
  virtual_on_prem_vpc_name   = "Virtual-On-Prem-VPC"
  region                     = "eu-central-1"

  tags = {
    ProjectName = local.project_name
    Environment = local.environment
    Challenge   = local.challenge
  }
}
