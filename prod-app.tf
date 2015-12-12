# security groups
resource "aws_security_group" "allow_internal_outgoing" {
  name = "allow_internal_outgoing"
  description = "Allow all internal traffic"
  vpc_id = "${aws_vpc.default.id}"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.0.0.0/24"]
  }
}

# instances
resource "aws_instance" "prod-web-001" {
  ami = "ami-5189a661"
  instance_type = "t2.micro"
  availability_zone = "us-west-2c"

  key_name = "${aws_key_pair.master.key_name}"

  subnet_id = "${aws_subnet.public.id}"
  security_groups = [
    "${aws_security_group.allow_all_outgoing.id}",
    "${aws_security_group.allow_ssh.id}",
    "${aws_security_group.allow_internal_outgoing.id}"
  ]

  tags {
    "Name" = "prod-web-001"
  }

  provisioner "chef" {
    environment = "_default"
    run_list = ["role[trainerade-app]"]
    node_name = "prod-web-001"
    server_url = "https://api.chef.io/organizations/stevenlu"
    validation_client_name = "${var.chef_validation_client_name}"
    validation_key = "${var.chef_validation_key}"

    connection {
      user = "ubuntu"
      private_key = "${var.ssh_key}"
      agent = false
    }
  }
}

# web elb
resource "aws_elb" "prod-elb" {
  name = "prod-elb"
  subnets = ["${aws_subnet.public.id}"]

  listener {
    instance_port = 8000
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8000/"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  instances = [
    "${aws_instance.prod-web-001.id}"
  ]
}