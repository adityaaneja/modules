terraform {
  backend "s3" {
    bucket = "mysql-aamyuser"
    key    = "stage/services/mysql-cluster/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_s3_bucket" "terraform_state" {

  bucket= "mysql-aamyuser"
  versioning {
      enabled = true
  }

  lifecycle {
     prevent_destroy = false
  }


}

resource "aws_db_instance" "example" {

   engine  = "mysql"
   allocated_storage = 10
   instance_class = "db.t2.micro"
   name = "example_database"
   username = "admin"
   password = "${var.db_password}"

}
