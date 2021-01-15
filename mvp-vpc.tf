resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "eks-vpc"
  }
}

resource "aws_subnet" "outposts_subnets" {
  count             = length(var.outposts_subnets)
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = element(concat(var.outposts_subnets, [""]), count.index)
  outpost_arn       = data.aws_outposts_outpost.otl.arn
  availability_zone = data.aws_outposts_outpost.otl.availability_zone
  tags = {
    Name = "op-subnet"
  }
}

resource "aws_subnet" "region_public_subnets" {
  count      = length(var.region_public_subnets)
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = element(concat(var.region_public_subnets, [""]), count.index)
  map_public_ip_on_launch = true
}

# resource "aws_subnet" "region_private_subnets" {

# }

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "otl-igw"
  }
}

resource "aws_route" "IGW_route" {
  route_table_id         = aws_vpc.eks_vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_ec2_local_gateway_route_table_vpc_association" "LGW_association" {
  local_gateway_route_table_id = data.aws_ec2_local_gateway_route_table.otl_lgw.id
  vpc_id                       = aws_vpc.eks_vpc.id
}

resource "aws_nat_gateway" "gw" {
  count = length(var.region_public_subnets) > 0 ? 1 : 0
  allocation_id = aws_eip.nat.id
  subnet_id = element(aws_subnet.region_public_subnets.*.id, 0)
}

resource "aws_eip" "nat" {
  vpc      = true
}

resource "aws_route_table" "internet" {
  vpc_id = aws_vpc.eks_vpc.id
   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "internet"
  }
}
  
resource "aws_route_table" "nat" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.gw.*.id, 0)
  }
  tags = {
    Name = "nat"
  }
}

# resource "aws_route_table_association" "public" {
#   subnet_id      = aws_subnet.region_subnet1.id
#   route_table_id = aws_route_table.internet.id
# }

# resource "aws_route_table_association" "public2" {
#   subnet_id      = aws_subnet.region_subnet2.id
#   route_table_id = aws_route_table.internet.id
# }

resource "aws_route_table_association" "public" {
  count = length(var.region_public_subnets)

  subnet_id      = element(aws_subnet.region_public_subnets.*.id, count.index)
  route_table_id = aws_route_table.internet.id
}

resource "aws_route_table_association" "private" {
    count = length(var.outposts_subnets)

    subnet_id = element(aws_subnet.outposts_subnets.*.id, count.index)
    route_table_id = aws_route_table.nat.id
}


