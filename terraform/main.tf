// terraform/main.tf
provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu_22_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_security_group" "ci_sg" {
  name_prefix = "ci-ephemeral-sg-"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "ci_ephemeral" {
  ami           = data.aws_ami.ubuntu_22_04.id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.ci_sg.id]
  tags = {
    Name = "ci-ephemeral"
    lifespan = "ephemeral"
    owner = "jenkins"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'instance created'"
    ]
    # we do provisioning with ansible later; keep this minimal
  }
}
