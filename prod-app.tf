# instances
resource "aws_instance" "prod-web-001" {
  ami = "ami-5189a661"
  instance_type = "t2.micro"
  availability_zone = "us-west-2c"

  key_name = "${aws_key_pair.master.key_name}"

  subnet_id = "${aws_subnet.default.id}"
  security_groups = [
    "${aws_security_group.allow_all_outgoing.id}",
    "${aws_security_group.allow_ssh.id}",
    "${aws_security_group.allow_internal_incoming.id}"
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
  subnets = ["${aws_subnet.default.id}"]

  security_groups = [
    "${aws_security_group.allow_all_outgoing.id}",
    "${aws_security_group.allow_http.id}"
  ]

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

  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  instances = [
    "${aws_instance.prod-web-001.id}"
  ]
}

# web db
resource "aws_db_instance" "prod-rds" {
  identifier = "prod-rds"

  allocated_storage = 20
  instance_class = "db.t2.micro"
  engine = "mysql"
  engine_version = "5.6.23"
  storage_type = "gp2"
  availability_zone = "us-west-2c"

  name = "trainerade"
  username = "root"
  password = "${var.rds_master_password}"

  vpc_security_group_ids = [
    "${aws_security_group.allow_internal_incoming.id}",
    "${aws_security_group.allow_all_outgoing.id}"
  ]
  db_subnet_group_name = "${aws_db_subnet_group.default.id}"
}

