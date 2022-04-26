
terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=3.0"
    }
  }
}


# can have multiple provider block with alias
provider "aws" {
  region = "us-east-1"
}



resource "aws_vpc" "my-vpc" {

  cidr_block = var.my_cidr
  tags = {
    Name = "my-vpc"
  }
}
# my internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "gw"
  }
}

resource "aws_subnet" "public-subnet-terra" {

  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = var.my_cidr_subnet
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-sunet-terraform"
  }
}

resource "aws_route_table" "my-rt-table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "my-rt-table"
  }

}


resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public-subnet-terra.id
  route_table_id = aws_route_table.my-rt-table.id
}

resource "aws_security_group" "allow_tls" {

  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "TLS from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "allow_tls"

    
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "mykey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0XzehMvlOGDZf0g7EBvxLTWSaC/UQQkacBMj+CQswxTtQzgKN0YPdxwfyNZh5DrTgM3jbuMZmjmisv/CBeBAiPZdiNb713IihpB1W2mJd08zMDpEkoSEvQo0fnrfz3/5Fi7VXvuaffa5Z1YM5MamfdusUgziRD6GXMfrYhBjNnHbURCOM2auzeOR6wqO8zf/Zz4oN1OWJNJWLUZojjHZC+YyKI6W6NHm7fFWAfbadAyYO5Qjqxj9JxsvhpEZcPLiV3O6XjyXxTt0aAsp2RSyAK5jXDdAtrra4et5j1+qsmi4WMIV11hnFPSaajhU+ONq1pXt6Uolhyrv69JHk3zhJ ariha@DESKTOP-9SAFHSD"
}

resource "aws_instance" "ubuntu_test" {


  ami             = "ami-04505e74c0741db8d"
  instance_type   = var.my_instance_type
  subnet_id       = aws_subnet.public-subnet-terra.id
  key_name        = "mykey"
  security_groups = [aws_security_group.allow_tls.id]

  # provisioner "file" {
  #   source      = "./tomcat.sh"
  #   destination = "/home/ubuntu/tomcat.sh"


  # }
  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod +777 /home/ubuntu/tomcat.sh",
  #     "./tomcat.sh"
  #   ]

  # }


  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("./mykey")
    timeout     = "4m"
  }



  tags = {
    Name = "my_ubuntu"
  }

}
