
locals {
  vpc_cidr = "172.31.0.0/16"
  zones = {
    "a" = { "public_cidr" : "172.31.1.0/24", "private_cidr" : "172.31.10.0/24" }
    "b" = { "public_cidr" : "172.31.2.0/24", "private_cidr" : "172.31.20.0/24" }
  }
}

########################
# VPC & Networking
########################

resource "aws_vpc" "main" {
  cidr_block       = local.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "apps-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "apps-igw"
  }
}

#resource "aws_eip" "nat" {
#  domain = "vpc"
#}

#resource "aws_nat_gateway" "nat" {
#  allocation_id = aws_eip.nat.id
#  subnet_id     = aws_subnet.public_1.id
#
#  depends_on = [aws_internet_gateway.igw]
#
#  tags = {
#    Name = "apps-nat-gw"
#  }
#}

########################
# Subnets
########################

resource "aws_subnet" "public" {
  for_each = local.zones

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value["public_cidr"]
  availability_zone       = "${var.aws_region}${each.key}"
  map_public_ip_on_launch = true

  tags = {
    Name = "apps-public-subnet-${each.key}"
  }
}

resource "aws_subnet" "private" {
  for_each = local.zones

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value["private_cidr"]
  availability_zone = "${var.aws_region}${each.key}"

  tags = {
    Name = "apps-private-subnet-${each.key}"
  }
}

########################
# Route Tables
########################

# Public route table (for NAT & IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "apps-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private route table (via NAT)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  for_each = aws_subnet.private

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = module.nat_instance[each.key].nat_instance_interface
  }

  tags = {
    Name = "apps-private-rt"
  }
}


resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

########################
# Security Groups
########################

resource "aws_security_group" "burrito" {
  name   = "burrito-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "mysql" {
  name   = "mysql-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "mongo" {
  name   = "mongo-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "redis" {
  name   = "redis-sg"
  vpc_id = aws_vpc.main.id
}

# Ingress Rules
resource "aws_security_group_rule" "burrito_ingress_8080" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.burrito.id
}

resource "aws_security_group_rule" "burrito_ingress_8081" {
  type              = "ingress"
  from_port         = 8081
  to_port           = 8081
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.burrito.id
}

# Egress Rules from Burrito to Services
resource "aws_security_group_rule" "burrito_to_mysql" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.burrito.id
  source_security_group_id = aws_security_group.mysql.id
}

resource "aws_security_group_rule" "burrito_to_mongo" {
  type                     = "egress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = aws_security_group.burrito.id
  source_security_group_id = aws_security_group.mongo.id
}

resource "aws_security_group_rule" "burrito_to_redis" {
  type                     = "egress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.burrito.id
  source_security_group_id = aws_security_group.redis.id
}

# Ingress Rules for MySQL, Mongo, Redis
resource "aws_security_group_rule" "mysql_ingress" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mysql.id
  source_security_group_id = aws_security_group.burrito.id
}

resource "aws_security_group_rule" "mongo_ingress" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mongo.id
  source_security_group_id = aws_security_group.burrito.id
}

resource "aws_security_group_rule" "redis_ingress" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redis.id
  source_security_group_id = aws_security_group.burrito.id
}

# Egress for HTTP/HTTPS
resource "aws_security_group_rule" "burrito_egress_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.burrito.id
}

resource "aws_security_group_rule" "burrito_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.burrito.id
}


resource "aws_security_group" "egress" {
  name   = "egress-sg"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nat_ingress" {
  name   = "nat-ingress-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########################
# ALB Security Group
########################

resource "aws_security_group" "alb" {
  name   = "alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "alb-sg"
  }
}
