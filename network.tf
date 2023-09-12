# get available AZs
data "aws_availability_zones" "available_azs" {}

# define VPC
resource "aws_vpc" "main_network" {
  cidr_block = "172.17.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

# define ${var.az_count} public subnets (one for each AZ)
resource "aws_subnet" "public_subnet" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.main_network.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available_azs.names[count.index]
  vpc_id                  = aws_vpc.main_network.id
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name_prefix}-public-subnet-${count.index}"
  }
}

# define ${var.az_count} public subnets (one for each AZ)
resource "aws_subnet" "private_subnet" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.main_network.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available_azs.names[count.index]
  vpc_id                  = aws_vpc.main_network.id
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.name_prefix}-private-subnet-${count.index}"
  }
}

# define IGW
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main_network.id
  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main_network.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}
