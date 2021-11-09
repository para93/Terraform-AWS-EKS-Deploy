#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "devsecops" {
  cidr_block = "10.0.0.0/16"

  tags = tomap({
    "Name"                                      = "terraform-eks-devsecops-node",
    "kubernetes.io/cluster/${var.cluster-devsecops}" = "shared",
  })
}

resource "aws_subnet" "devsecops" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.devsecops.id

  tags = tomap({
    "Name"                                      = "terraform-eks-devsecops-node",
    "kubernetes.io/cluster/${var.cluster-devsecops}" = "shared",
  })
}

resource "aws_internet_gateway" "devsecops" {
  vpc_id = aws_vpc.devsecops.id

  tags = {
    Name = "terraform-eks-devsecops-igw"
  }
}

resource "aws_route_table" "devsecops" {
  vpc_id = aws_vpc.devsecops.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devsecops.id
  }
}

resource "aws_route_table_association" "devsecops" {
  count = 2

  subnet_id      = aws_subnet.devsecops.*.id[count.index]
  route_table_id = aws_route_table.devsecops.id
}
