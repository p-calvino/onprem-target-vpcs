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
