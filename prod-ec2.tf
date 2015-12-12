# instances
resource "aws_instance" "prod-web-001" {
  ami = "ami-5189a661"
  instance_type = "t2.micro"
  availability_zone = "us-west-2c"

  key_name = "${aws_key_pair.master.key_name}"

  subnet_id = "${aws_subnet.public.id}"
  security_groups = [
    "${aws_security_group.allow_all_outgoing.id}",
    "${aws_security_group.allow_ssh.id}"
  ]

  tags {
    "Name" = "prod-web-001"
  }

  provisioner "chef" {
    environment = "_default"
    run_list = ["role[trainerade-app]"]
    node_name = "prod-web-001"
    server_url = "https://api.chef.io/organizations/stevenlu"
    validation_client_name = "terraform-validator"
    validation_key_path = "./chef-validator.pem"

    connection {
      user = "ubuntu"
      key_file = "./master.pem"
      agent = false
    }
  }
}

# web elb
resource "aws_elb" "prod-elb" {
  name = "prod-elb"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

  listener {
    instance_port = 10010
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:10010/"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  subnets = ["${aws_subnet.public.id}"]

  instances = []
}