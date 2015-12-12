resource "dnsimple_record" "root" {
  domain = "trainerade.com"
  name = ""
  value = "${aws_elb.prod-elb.dns_name}"
  type = "ALIAS"
  ttl = 3600
}