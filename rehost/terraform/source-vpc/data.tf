# All data resources

data "aws_ami" "ubuntu_image" {
  most_recent = true
  owners      = [local.ubuntu_ami_owner]

  filter {
    name   = "name"
    values = [local.ubuntu_ami_name]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_iam_policy" "agent_policy" {
  arn = "arn:aws:iam::aws:policy/AWSApplicationMigrationAgentPolicy"
}
