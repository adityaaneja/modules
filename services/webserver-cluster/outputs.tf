output "s3_bucket_arn" {
    value = "${aws_s3_bucket.terraform_state.arn}"
  }

output "asg_name" {
    value = "${aws_autoscaling_group.example.name}"
}

output "elb_dns_name" {
    value = "${aws_elb.example.dns_name}"
}
output "elb_security_group_id" {
    value = "${aws_security_group.elb.id}"
}
