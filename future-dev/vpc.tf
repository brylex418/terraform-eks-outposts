###Locals###

locals {
  max_subnet_length = max(
    length(var.region_public_subnets),
    length(var.region_private_subnets),
    length(var.outposts_private_subnets)
  )
  vpc_id = element(
    concat(
      aws_vpc.this.*.id,
      [""],
    ),
    0,
  )
}
###VPC Resources###
resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
    var.vpc_tags,
  )
}

resource "aws_subnet" "region_public_subnet" {
  count                   = length(var.region_public_subnets)
  vpc_id                  = local.vpc_id
  cidr_block              = element(concat(var.region_public_subnets, [""]), count.index)
  availability_zone       = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch = var.map_public_ip_on_launch
}

resource "aws_subnet" "region_private_subnet" {
  count                   = length(var.region_private_subnets)
  vpc_id                  = local.vpc_id
  cidr_block              = element(concat(var.region_private_subnets, [""]), count.index)
  availability_zone       = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch = var.map_public_ip_on_launch
}
# resource "aws_subnet" "outposts_subnet" {

# }

resource "aws_internet_gateway" "this" {
  count  = length(var.region_public_subnets) > 0 ? 1 : 0
  vpc_id = local.vpc_id
}

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway == true ? 1 : 0
  vpc = true

}

resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway == true ? 1 : 0
  depends_on = [aws_internet_gateway.this]
  subnet_id = element(
    aws_subnet.region_public_subnet.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )
  allocation_id = element(
    local.nat_gateway_ips,
    var.single_nat_gateway ? 0 : count.index,
  )
}

# resource "aws_route" "private_nat_gateway" {
#   count = var.enable_nat_gateway == true ? 1 : 0

#   route_table_id         = element(aws_route_table.private.*.id, count.index)
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = element(aws_nat_gateway.this.*.id, count.index)

#   timeouts {
#     create = "5m"
#   }
# }