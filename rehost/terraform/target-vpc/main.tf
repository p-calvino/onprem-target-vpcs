module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.target_vpc_name
  cidr = local.vpc_cidr

  azs                  = [data.aws_availability_zones.available.names[0]]
  private_subnets      = [local.private_application_server, local.private_db_servers_cidr, local.private_mgn]
  public_subnets       = [local.public_cidr]
  private_subnet_names = ["App-SB-Private", "DB-SB-Private", "Staging-SB-Private"]
  public_subnet_names  = ["Public-SB"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

resource "aws_vpc_peering_connection" "squint" {

  peer_vpc_id = data.aws_vpc.source_vpc.id
  vpc_id      = module.vpc.vpc_id
  auto_accept = true
}

resource "aws_route" "source_public_vpc" {
  count                     = length(data.aws_route_tables.source_vpc.ids)
  route_table_id            = data.aws_route_tables.source_vpc.ids[count.index]
  destination_cidr_block    = local.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.squint.id
}

resource "aws_route" "target_public_vpc" {
  count                     = length(module.vpc.public_route_table_ids)
  route_table_id            = module.vpc.public_route_table_ids[count.index]
  destination_cidr_block    = data.aws_vpc.source_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.squint.id
}

resource "aws_route" "target_private_vpc" {
  count                     = length(module.vpc.private_route_table_ids)
  route_table_id            = module.vpc.private_route_table_ids[count.index]
  destination_cidr_block    = data.aws_vpc.source_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.squint.id
}

resource "aws_security_group" "webserver" {
  name        = local.webserver_sg_name
  description = "Security group for Webserver"
  vpc_id      = module.vpc.vpc_id

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
    Name = "Target-Web-SG"
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
    Name = "Target-DB-SG"
  }
}
