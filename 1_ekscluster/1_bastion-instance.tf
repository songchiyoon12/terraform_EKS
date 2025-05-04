data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

}

variable "instance_type" {
  default = "t3.micro"
}

variable "instance_keypair" {
  default = "key-pair"
}



resource "aws_eip" "bastion_eip" {
  depends_on = [ module.ec2_public]
  instance = module.ec2_public.id
  domain = "vpc"
  tags = {
    Name = var.cluster_name
  }
}



module "ec2_public" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.5.0"

  name                   = "${var.cluster_name}-BastionHost"
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name               = var.instance_keypair
  subnet_id               =  module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.public_bastion_sg.security_group_id]

  tags = {
    Name = var.cluster_name
  }

}

module "public_bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"

  version = "5.1.0"

  name = "${var.cluster_name}-public-bastion-sg"
  description = "Security Group with SSH port open for everybody (IPv4 CIDR), egress ports are all world open"
  vpc_id = module.vpc.vpc_id

  ingress_rules = ["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules = ["all-all"]
  tags = {
    Name = var.cluster_name
  }
}