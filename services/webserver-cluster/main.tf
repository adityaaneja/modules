terraform {
  backend "s3" {
    bucket = "webcluster-aamyuser"
    key    = "stage/services/webserver-cluster/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}



resource "aws_s3_bucket" "terraform_state" {
  
  bucket= "webcluster-aamyuser"
  versioning {
      enabled = true
  }

  lifecycle {
     prevent_destroy = false
  }


}



data "terraform_remote_state" "db" {

   backend = "s3"
   config {
      bucket = "${var.db_remote_state_bucket}"
      key = "${var.db_remote_state_key}"
      region = "us-east-1"
   }

}

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
     server_port = "${var.server_port}"
     db_address = "${data.terraform_remote_state.db.address}"
     db_port = "${data.terraform_remote_state.db.port}"
  }
}


data "aws_availability_zones" "all" {}

resource "aws_launch_configuration" "example" {

   image_id 	= "ami-da05a4a0"
   instance_type = "${var.instance_type}"
   security_groups = ["${aws_security_group.instance.id}"]
   user_data = "${data.template_file.user_data.rendered}"

  key_name="mykey"   


  lifecycle {
   create_before_destroy = true
  }
}




resource "aws_autoscaling_group" "example" {
  
  launch_configuration = "${aws_launch_configuration.example.id}"
  min_size = "${var.min_size}"
  max_size= "${var.max_size}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  load_balancers = ["${aws_elb.example.name}"]
  health_check_type = "ELB"
 
  tag {
    key = "Name"
    value = "${var.cluster_name}-example"
    propagate_at_launch = true
   }
}

resource "aws_security_group" "instance" {
	name = "${var.cluster_name}-instance"
	ingress {
		from_port = "${var.server_port}"
		to_port = "${var.server_port}"
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		from_port = "${var.ssh_port}"
                to_port ="${var.ssh_port}"
                protocol = "tcp"
                cidr_blocks = ["142.244.161.85/32"]
        }

    lifecycle {
   create_before_destroy = true
  }

}


resource "aws_elb" "example" {

   name = "${var.cluster_name}-example"
   availability_zones = ["${data.aws_availability_zones.all.names}"]
   security_groups = ["${aws_security_group.elb.id}"]
   listener {
      lb_port = 80
      lb_protocol = "http"
      instance_port = "${var.server_port}"
      instance_protocol = "http"
  }

  health_check {
      healthy_threshold = 2
      unhealthy_threshold = 2
      timeout = 3
      interval = 30
      target   = "HTTP:${var.server_port}/"
  }

}


/*
resource "aws_security_group" "elb" {
  name = "${var.cluster_name}-elb"
  

 ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

*/

resource "aws_security_group" "elb" {
  name = "${var.cluster_name}-elb"
}

 resource "aws_security_group_rule" "allow_http_inbound" {
  type = "ingress"
  security_group_id = "${aws_security_group.elb.id}"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_outbound" {

  type = "egress"
  security_group_id = "${aws_security_group.elb.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

