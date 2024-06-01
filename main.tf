
# Define provider and region
provider "aws" {
  region = "us-east-1"  
}

# Attach IAM policies to the EKS node role
resource "aws_iam_role_policy_attachment" "eks_node_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}


# Create EKS cluster
resource "aws_eks_cluster" "my_cluster" {
  name        = "my-cluster"
  role_arn    = aws_iam_role.eks_cluster_role.arn
  version     = "1.29"
  
  vpc_config {
    subnet_ids         = ["subnet-01b32a3aaa42658c3", "subnet-06b9233cf6cb96132"]  # Replace with your subnet IDs
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }
}

# Create EKS node group
resource "aws_eks_node_group" "my_node_group" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "my-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  
  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 1
  }
 subnet_ids = ["subnet-01b32a3aaa42658c3", "subnet-06b9233cf6cb96132"]
}


