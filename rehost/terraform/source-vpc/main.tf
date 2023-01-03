# Main resources: e.g., VPCs, Subnets, EC2 instances, etc.

# VPC, Subnets, Route Tables and Gateways

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs             = [data.aws_availability_zones.available.names[0]]
  private_subnets = [local.private_cidr]
  public_subnets  = [local.public_cidr]
  private_subnet_names = ["OnPrem-DB-Private"]
  public_subnet_names  = ["OnPrem-Web-Public"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

# Security Groups

resource "aws_security_group" "webserver" {
  name        = local.webserver_sg_name
  description = "Security group for Webserver"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH connection into the server"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.allowed_ssh_ip}/32"]
  }

  ingress {
    description = "HTTP connection into the server"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS connection into the server"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "OnPrem-Web-SG"
  }

}

resource "aws_security_group" "database" {
  name        = local.database_sg_name
  description = "Security group for database"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "SSH connection into the server"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver.id]
  }

  ingress {
    description     = "Database connection into the server"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "OnPrem-DB-SG"
  }
}

# Generating Key Pair

resource "tls_private_key" "rehost_migration" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = local.keypair_name
  public_key = tls_private_key.rehost_migration.public_key_openssh
}

# EC2 Instances

resource "aws_instance" "webserver" {
  ami                    = data.aws_ami.ubuntu_image.id
  instance_type          = local.ec2_type_web
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.webserver.id]
  key_name               = aws_key_pair.generated_key.key_name
  user_data              = file("${path.module}/files/scripts/web_userdata.sh")

  tags = {
    Name = "OnPrem-Webserver"
  }
}

resource "aws_instance" "database" {
  ami                    = data.aws_ami.ubuntu_image.id
  instance_type          = local.ec2_type_db
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.database.id]
  key_name               = aws_key_pair.generated_key.key_name
  user_data              = file("${path.module}/files/scripts/db_userdata.sh")

  tags = {
    Name = "OnPrem-Database"
  }
}

# IAM User for Replication Agent

resource "aws_iam_user" "replication_agent" {
  name = "User_for_replication"
  path = "/"
}

resource "aws_iam_access_key" "user_access_key" {
  user = aws_iam_user.replication_agent.name
}

resource "aws_iam_policy_attachment" "attach-policy" {
  name       = "agent-migration-policy-attachment"
  users      = [aws_iam_user.replication_agent.name]
  policy_arn = data.aws_iam_policy.agent_policy.arn
}
