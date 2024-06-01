# Define provider and region
provider "aws" {
  region = "us-east-1"  
}

# Create IAM role for EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
  count = length(aws_iam_role.eks_cluster_role) == 0 ? 1 : 0  # Skip creation if already exists

  name               = "eks-cluster-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach IAM policies to the EKS cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  count = length(aws_iam_role_policy_attachment.eks_cluster_policy_attachment) == 0 ? 1 : 0  # Skip creation if already exists

  role       = aws_iam_role.eks_cluster_role[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Create IAM role for EKS nodes
resource "aws_iam_role" "eks_node_role" {
  count = length(aws_iam_role.eks_node_role) == 0 ? 1 : 0  # Skip creation if already exists

  name               = "eks-node-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach IAM policies to the EKS node role
resource "aws_iam_role_policy_attachment" "eks_node_policy_attachment" {
  count = length(aws_iam_role_policy_attachment.eks_node_policy_attachment) == 0 ? 1 : 0  # Skip creation if already exists

  role       = aws_iam_role.eks_node_role[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Create security group for EKS cluster
resource "aws_security_group" "eks_cluster_sg" {
  count = length(aws_security_group.eks_cluster_sg) == 0 ? 1 : 0  # Skip creation if already exists

  name        = "eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = "vpc-0621b188e7dc1b0da"  

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EKS cluster
resource "aws_eks_cluster" "my_cluster" {
  count = length(aws_eks_cluster.my_cluster) == 0 ? 1 : 0  # Skip creation if already exists

  name        = "my-cluster"
  role_arn    = aws_iam_role.eks_cluster_role[count.index].arn
  version     = "1.21"
  
  vpc_config {
    subnet_ids         = ["subnet-01b32a3aaa42658c3", "subnet-06b9233cf6cb96132"]  # Replace with your subnet IDs
    security_group_ids = [aws_security_group.eks_cluster_sg[count.index].id]
  }
}

# Create EKS node group
resource "aws_eks_node_group" "my_node_group" {
  count = length(aws_eks_node_group.my_node_group) == 0 ? 1 : 0  # Skip creation if already exists

  cluster_name    = aws_eks_cluster.my_cluster[count.index].name
  node_group_name = "my-node-group"
  node_role_arn   = aws_iam_role.eks_node_role[count.index].arn
  
  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 1
  }

  subnet_ids = ["subnet-01b32a3aaa42658c3", "subnet-06b9233cf6cb96132"]
}

