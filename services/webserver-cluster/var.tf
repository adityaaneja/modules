
variable "server_port" {
   description = "The port the server will use to serve http requests"
   default=8080
   type="string"
}

variable "ssh_port" {
   description = "The ssh server port"
   default=22
   type="string"
}

variable "cluster_name" {
   description = "The name of use for all the cluster resources"
}

variable "db_remote_state_bucket" {
   description = "The path of the S3 bucket for the database's remote state"
}

variable "db_remote_state_key" {
   description = "The path for the databases's remote state in s3"
}

variable "instance_type" {
   description = "The type of EC2 Instances to run (e.g. t2.micro)"
}

variable "min_size" {
   description = "The minimum number of EC2 Instances in the ASG"
}

variable "max_size" {
   description = "The maximum number of EC2 Instances in the ASG"
}

