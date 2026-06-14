
resource "tls_private_key" "datacenter_kp" {
  algorithm = "RSA"
  rsa_bits  = 4096

}

resource "local_file" "private_key" {
  content  = tls_private_key.datacenter_kp.private_key_pem
  filename = "datacenter-kp.pem"
  file_permission = "0600"
}
resource "aws_key_pair" "datacenter_kp" {
  key_name   = "datacenter-kp"
  public_key = tls_private_key.datacenter_kp.public_key_openssh

}


resource "aws_instance" "Jankins_server" {
  ami = var.jenkins_sonar_ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name   = aws_key_pair.datacenter_kp.key_name # "datacenter-kp"
  count = 1
  user_data = file("jenkins-setup.sh")

  tags = {
    Name = "Jankins_server"
  }
}
resource "aws_instance" "sonarqube_server" {
  ami = var.jenkins_sonar_ami
  instance_type = var.instance_type
   vpc_security_group_ids = [aws_security_group.sonar_sg.id]
  key_name   = aws_key_pair.datacenter_kp.key_name # "datacenter-kp"
  count = 1
  user_data = file("sonar-setup.sh")

  tags = {
    Name = "sonarqube_server"
  }
}

resource "aws_instance" "nexus_server" {
  ami = var.nexus_ami
  instance_type = var.instance_type
   vpc_security_group_ids = [aws_security_group.nexus_sg.id]
  key_name   = aws_key_pair.datacenter_kp.key_name # "datacenter-kp"
  count = 1
  user_data = file("nexus-setup.sh")

  tags = {
    Name = "nexus_server"
  }
}
# /* resource "aws_key_pair" "terraform_keypair" {
#   key_name   = "demokey"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCXtKjp0RmSROkRTllgi7vpESAeJsQ+uoR5bSXx/igICbuILRS8mxSPqg5reT4lCrPPbqYtuh2U7G8JtC0O8FlJZ6dQAwKJfrnFSU496QA6kbKz7k/31oV8O+z295IJPJj4QgChw53VxBPWhqecOK4SDb9ETdj4sLtXYWDmBwDur+f6tgWrsrsNN+eHA5+FEs4G3394Fv02HZZY0eA/DQFfY6TbplCL4F0q5cjqKM10/8cGXTXDwSxbiqDPHuLbnmJxPFINEZ9zVP4axXlwjuzrdIGMYNtZuQ5ph4G5NEuaOXMn0urDsdWZ26X5TLeVbsRH7may/jNEJSUXEK2O8cV5g/6gALzRD6oVETP1DRrnoNurZHDRTMwbS/Qk6R369RzIiNKXVBlCHHAAxEHB4A5CXphQD6P3zxT9UdmhPaICFpbOeg1F4a0ZrvYlYK0RU0FpOy92MjZzOQ5NJuyNILgfUX4WfIqeMp6RPHxp+Rp1EmJ1dMP2pTCOAV4mbLZANrIUlB5uPiuWfpcAXgBnY7t8IihNXlbJV1At6g20nGcHXwxIYUCvDwT/Ud0kO1bYWkj0uC8+JmxlRcK3HjjG3kZfRzpfZ4MXv+YQUZPlGK8LgHaVLO6k1OtdRuIWIA7KuZrgaOjXrWo4j2Ork3Ru1MUZMgElX4zkMpZkyutUTLMIkQ== gizac@DESKTOP-G86KF7Q"
# #} */
# Jenkins Security Group
resource "aws_security_group" "jenkins_sg" { 
    name = "jenkins-sg" 
    description = "Allow http & SSH inbound traffic" 

    ingress {
     description = "jenkins SSH Access"
     from_port = 22 
     to_port = 22 
     protocol = "tcp" 
     cidr_blocks = ["0.0.0.0/0"] 
     } 
    ingress {
    description = "allow 8080 traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
     }

     egress  { 
       from_port = 0
       to_port = 0 
       protocol = "-1"
       cidr_blocks = ["0.0.0.0/0"] 
       }

         tags = { Name = "jenkins_sg"
          }
           }
#  SonarQube Security Group
resource "aws_security_group" "sonar_sg" { 
    name = "sonar-sg" 
    description = "listen on 9000 and allow from jenkins & SSH inbound traffic" 

    ingress {
     description = "sonar SSH Access"
     from_port = 22 
     to_port = 22 
     protocol = "tcp" 
     cidr_blocks = ["0.0.0.0/0"] 
     } 
    ingress {
    description = "allow 900 traffic"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
     }
      ingress {
    description = "allow traffic from jenkins_sg"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]
     }
     
     egress  { 
       from_port = 0
       to_port = 0 
       protocol = "-1"
       cidr_blocks = ["0.0.0.0/0"] 
       }

         tags = { Name = "sonar_sg"
          }
        }     
#  SonarQube Security Group
resource "aws_security_group" "nexus_sg" { 
    name = "nexus-sg" 
    description = "listen on 8081 and allow from jenkins & SSH inbound traffic" 

    ingress {
     description = "nexus SSH Access"
     from_port = 22 
     to_port = 22 
     protocol = "tcp" 
     cidr_blocks = ["0.0.0.0/0"] 
     } 
    ingress {
    description = "allow 8081 traffic"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
     }
      ingress {
    description = "allow traffic from jenkins_sg"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]
     }
     
     egress  { 
       from_port = 0
       to_port = 0 
       protocol = "-1"
       cidr_blocks = ["0.0.0.0/0"] 
       }

         tags = { Name = "nexus_sg"
          }
        }           
# # this vpc not attached with ec2 
# resource "aws_vpc" "main" {
#   cidr_block       = "10.0.0.0/16"
#   instance_tenancy = "default"

#   tags = {
#     Name = "payment_vpc"
#   }
# }
# #it is good  you tube vpc creation :https://www.youtube.com/watch?v=wx7L6snkrTU