variable "instance_type" {
    type = string
    default = "t3.medium"
}
variable "jenkins_sonar_ami" {
    type = string
    default = "ami-0d13e2317a7e75c95"
}

variable "nexus_ami" {
    type = string
    default = "ami-09e69ca1171857250"
}

# variable "aws_security_group" {
#     type = string
#     default = ""
# }

variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
default = "us-west-2"
} 