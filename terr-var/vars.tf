variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "sub_cidr" {
  default = "10.0.1.0/24"
}

variable "az" {
  default = "us-east-1a"
}

variable "ami-name" {
  default = "ami-053b0d53c279acc90"
}

variable "inst-type" {
  default = "t2.micro"
}

variable "key-name" {
  default = "k8s"
}
