# Terraform configuration block (including required_version, backend, & required_providers)
# Terraform providers (e.g., aws, tls, etc.)

terraform {
  required_providers {
    aws = {
      version = ">= 4.40.0, < 4.41.0"
      source  = "hashicorp/aws"
    }
  }

  backend "s3" {
    region         = "eu-central-1"
    bucket         = "group3-capci-tfstates-238466548014"
    key            = "source-vpc-rehost.tfstate"
    dynamodb_table = "tf-statelock-mgn-rehost"
    encrypt        = "true"
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region = local.region
  default_tags {
    tags = merge(
      local.tags
    )
  }
}
