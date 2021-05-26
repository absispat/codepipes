module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"
  # insert the 18 required variables here
  #public_subnets  = ["172.32.0.0/24", "172.32.3.0/24"]
  cidr = var.cidr
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

 enable_nat_gateway = true
 enable_vpn_gateway = true
}


resource "aws_key_pair" "deployer" {
  key_name   = "copepipekey-key"
  public_key = var.pubkey
  #public_key = file("/Users/absipat/.ssh/id_rsa.pub")
}




data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners      = ["amazon"]
}




resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "ingress all"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}


resource "aws_instance" "web" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t3.micro"
  subnet_id       = module.vpc.public_subnets[0]
  security_groups = [aws_security_group.allow_all.id]
  key_name        = aws_key_pair.deployer.id
  user_data = file("apache.sh")
  associate_public_ip_address = true
  tags = {
    Name = "HelloWorld"
  }
}
