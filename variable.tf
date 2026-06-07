variable "instance_type" {
    type = string
    default = "t3.medium"
}
variable "amiid" {
    type = string
    default = "ami-0d13e2317a7e75c95"
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