# starts up our virtual private cloud
# where all of our resources will exist

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

# connects the VPC to the internet
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# subnets
resource "aws_subnet" "a" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-2c"
  map_public_ip_on_launch = true

  tags {
    Name = "default"
  }
}

resource "aws_subnet" "b" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = true

  tags {
    Name = "default"
  }
}

resource "aws_subnet" "c" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-2c"
  map_public_ip_on_launch = true

  tags {
    Name = "default"
  }
}

resource "aws_db_subnet_group" "default" {
  name = "prod-rds"
  description = "DB subnets"
  subnet_ids = [
    "${aws_subnet.a.id}",
    "${aws_subnet.b.id}",
    "${aws_subnet.c.id}"
  ]
}

# routing tables
resource "aws_route_table" "default" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
}

resource "aws_route_table_association" "default" {
  subnet_id = "${aws_subnet.a.id}"
  route_table_id = "${aws_route_table.default.id}"
}

resource "aws_route_table_association" "default" {
  subnet_id = "${aws_subnet.b.id}"
  route_table_id = "${aws_route_table.default.id}"
}

resource "aws_route_table_association" "default" {
  subnet_id = "${aws_subnet.c.id}"
  route_table_id = "${aws_route_table.default.id}"
}

# security groups
resource "aws_security_group" "allow_all_outgoing" {
  name = "allow_all_outgoing"
  description = "Allow all outgoing traffic"
  vpc_id = "${aws_vpc.default.id}"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_internal_incoming" {
  name = "allow_internal_incoming"
  description = "Allow all internal traffic"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.0.0.0/24"]
  }
}

resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
  description = "Allow SSH connections for servers"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_http" {
  name = "allow_http"
  description = "Allow HTTP (Port 80)"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}