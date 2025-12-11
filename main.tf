terraform {
  backend "s3" {
    bucket = "tfstate-bucket-929db8f5"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}

# VPC

resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# 1) Public Subnet (web)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = var.public_cidr
  availability_zone       = var.az1
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-web"
  }
}

# 2) Private Subnet (app)
resource "aws_subnet" "private_app_subnet" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = var.private_app_cidr
  availability_zone = var.az2
  tags = {
    Name = "${var.project_name}-private-app"
  }
}

# 3) Private Subnet (db)
resource "aws_subnet" "private_db_subnet" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = var.private_db_cidr
  availability_zone = var.az1
  tags = {
    Name = "${var.project_name}-private-db"
  }
}

# Internet Gateway (Web)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "${var.project_name}-IGW"
  }
}

# NAT Gateway (for App + DB Tiers)

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}


resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = "${var.project_name}-NAT"
  }
}

# Route Tables

# Public RT (Internet)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Private RT (App + DB via NAT)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private_app_assoc" {
  subnet_id      = aws_subnet.private_app_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_db_assoc" {
  subnet_id      = aws_subnet.private_db_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# Security Groups

# Web SG (Internet → Web Server or ALB)
resource "aws_security_group" "web-sg" {
  vpc_id = aws_vpc.my-vpc.id
  name   = "${var.project_name}-web-sg"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# App SG (Web → App)
resource "aws_security_group" "app-sg" {
  vpc_id = aws_vpc.my-vpc.id
  name   = "${var.project_name}-app-sg"

  ingress {
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
    security_groups = [aws_security_group.web-sg.id]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# DB SG (App → DB)
resource "aws_security_group" "db-sg" {
  vpc_id = aws_vpc.my-vpc.id
  name   = "${var.project_name}-db-sg"

  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    security_groups = [aws_security_group.app-sg.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instances

# Web Server (Public)
resource "aws_instance" "web_server" {
  subnet_id              = aws_subnet.public_subnet.id
  ami                    = var.ami
  instance_type          = var.instance
  key_name               = var.key
  vpc_security_group_ids = [aws_security_group.web-sg.id]

  tags = {
    Name = "${var.project_name}-web-server"
  }
}

# App Server (Private)
resource "aws_instance" "app_server" {
  subnet_id              = aws_subnet.private_app_subnet.id
  ami                    = var.ami
  instance_type          = var.instance
  key_name               = var.key
  vpc_security_group_ids = [aws_security_group.app-sg.id]

  tags = {
    Name = "${var.project_name}-app-server"
  }
}

# DB Server (Private)
resource "aws_instance" "db_server" {
  subnet_id              = aws_subnet.private_db_subnet.id
  ami                    = var.ami
  instance_type          = var.instance
  key_name               = var.key
  vpc_security_group_ids = [aws_security_group.db-sg.id]

  tags = {
    Name = "${var.project_name}-db-server"
  }
}
