provider "aws" {
  region = "us-east-1"
  profile = "VanessaBezerra"
}

variable "projeto" {
  description = "Nome do projeto"
  type        = string
  default     = "VExpenses"
}

variable "candidato" {
  description = "Nome do candidato"
  type        = string
  default     = "Luzia-Vanessa-Bezerra-Gomes"
}

variable "allowed_ssh_ip" {
  description = "IP permitido para acesso SSH"
  type        = string
  default     = "203.0.113.25" # Modifique aqui para um IP específico para maior segurança
}

variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR da Sub-rede"
  type        = string
  default     = "10.0.1.0/24"
}

resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "${var.projeto}-${var.candidato}-key"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.projeto}-${var.candidato}-vpc"
  }
}

resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.subnet_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "${var.projeto}-${var.candidato}-subnet"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.projeto}-${var.candidato}-igw"
  }
}

resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "${var.projeto}-${var.candidato}-route_table"
  }
}

resource "aws_route_table_association" "main_association" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}

resource "aws_security_group" "main_sg" {
  name        = "VExpenses-Luzia-Vanessa-Bezerra-Gomes-sg"
  description = "Grupo de Segurança para VExpenses"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.0/24"]  # Corrija o CIDR aqui
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Permitir todo o tráfego de saída
    cidr_blocks = ["0.0.0.0/0"]  # Permitir tráfego de saída para qualquer lugar
  }

  tags = {
    Name = "VExpenses-Luzia-Vanessa-Bezerra-Gomes-sg"
  }
}

data "aws_ami" "debian12" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"]
}

resource "aws_instance" "debian_ec2" {
  ami                    = data.aws_ami.debian12.id
  instance_type         = "t2.micro"
  subnet_id             = aws_subnet.main_subnet.id
  key_name              = aws_key_pair.ec2_key_pair.key_name
  security_groups       = [aws_security_group.main_sg.name]

  associate_public_ip_address = true

  root_block_device {
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get upgrade -y
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "${var.projeto}-${var.candidato}-ec2"
  }
}

# Declaração do volume EBS
resource "aws_ebs_volume" "my_ebs_volume" {
  availability_zone = aws_subnet.main_subnet.availability_zone
  size             = 20  # Tamanho do volume em GB
  tags = {
    Name = "${var.projeto}-${var.candidato}-ebs-volume"
  }
}

# Declaração do cofre de backup
resource "aws_backup_vault" "default_vault" {
  name = "${var.projeto}-backup-vault"
  tags = {
    Name = "${var.projeto}-${var.candidato}-backup-vault"
  }
}

# Declaração do plano de backup
resource "aws_backup_plan" "ebs_backup_plan" {
  name = "EBS-Backup-Plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.default_vault.name
    schedule          = "cron(0 12 * * ? *)" # Todos os dias ao meio-dia UTC
    lifecycle {
      delete_after = 30 # Mantenha os backups por 30 dias
    }
  }
}

# Criação do IAM Role para backup
resource "aws_iam_role" "backup_role" {
  name = "${var.projeto}-backup-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "backup.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })
}

# Seleção de backup
resource "aws_backup_selection" "ebs_selection" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "EBS-Backup-Selection"

  plan_id = aws_backup_plan.ebs_backup_plan.id

  resources = [
    aws_ebs_volume.my_ebs_volume.arn
  ]
}

output "private_key" {
  description = "Chave privada para acessar a instância EC2"
  value       = tls_private_key.ec2_key.private_key_pem
  sensitive   = true
}

output "ec2_public_ip" {
  description = "Endereço IP público da instância EC2"
  value       = aws_instance.debian_ec2.public_ip
}