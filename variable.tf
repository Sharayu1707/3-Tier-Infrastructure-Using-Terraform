variable "region" {
  default = "ap-south-1"
}
variable "az1" {
  default = "ap-south-1a"
}
variable "vpc_cidr" {
  default =  "10.0.0.0/16"
}
variable "private_cidr" {
  default = "10.0.0.0/20"
}
variable "public_cidr" {
  default = "10.0.16.0/20"
}
variable "az2" {
  default = "ap-south-1b"
}
variable "project_name" {
  default = "FCT"
}
variable "igw_cidr" {
  default = "0.0.0.0/0"
}
variable "ami" {
  default = "ami-00ca570c1b6d79f36"
}
variable "instance" {
  default = "t2.micro"
}
variable "key" {
  default = "jenkins"
}
variable "private_app_cidr" {
  default = "10.0.32.0/20"
}
variable "private_db_cidr" {
  default = "10.0.48.0/20"
}
