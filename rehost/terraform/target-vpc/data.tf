# All data resources

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "source_vpc" {
  tags = {
    Name = local.virtual_on_prem_vpc_name
  }
}

data "aws_route_tables" "source_vpc" {
  vpc_id = data.aws_vpc.source_vpc.id
}
