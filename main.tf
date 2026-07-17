# Three EC2 instances for a sandbox kubeadm cluster: one control plane,
# two workers, in a small dedicated VPC with a single public subnet.

resource "aws_vpc" "k8s" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project}-vpc"
    Project = var.project
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.k8s.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-public"
    Project = var.project
  }
}

resource "aws_internet_gateway" "k8s" {
  vpc_id = aws_vpc.k8s.id

  tags = {
    Name    = "${var.project}-igw"
    Project = var.project
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.k8s.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s.id
  }

  tags = {
    Name    = "${var.project}-public"
    Project = var.project
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Latest Ubuntu 24.04 LTS for arm64 (matches the t4g instance type; switch
# the architecture filter to x86_64 if you change to a t3/t3a type).
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-*-server-*"]
  }
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Sandbox convenience: generate the SSH key pair in Terraform and write the
# private key next to the config. Note the private key is also stored in the
# remote state — acceptable for a sandbox, not for production.
resource "tls_private_key" "ssh" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "k8s" {
  key_name   = "${var.project}-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh.private_key_openssh
  filename        = "${path.module}/${var.project}-key.pem"
  file_permission = "0600"
}

resource "aws_security_group" "k8s_nodes" {
  name        = "${var.project}-nodes"
  description = "Sandbox Kubernetes nodes"
  vpc_id      = aws_vpc.k8s.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "Kubernetes API server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "All traffic between cluster nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project}-nodes"
    Project = var.project
  }
}

resource "aws_instance" "k8s_node" {
  count = var.node_count

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  key_name               = aws_key_pair.k8s.key_name
  vpc_security_group_ids = [aws_security_group.k8s_nodes.id]

  # Some CNI plugins route pod traffic with IPs the fabric doesn't know
  # about; disabling the check avoids silent packet drops later.
  source_dest_check = false

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name    = "${var.project}-${count.index == 0 ? "control-plane" : "worker-${count.index}"}"
    Role    = count.index == 0 ? "control-plane" : "worker"
    Project = var.project
  }
}
