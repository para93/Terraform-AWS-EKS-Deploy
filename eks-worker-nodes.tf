#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "devsecops-node" {
  name = "terraform-eks-devsecops-node"

  assume_role_policy = <<POLICY
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
POLICY
}

resource "aws_iam_role_policy_attachment" "devsecops-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.devsecops-node.name
}

resource "aws_iam_role_policy_attachment" "devsecops-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.devsecops-node.name
}

resource "aws_iam_role_policy_attachment" "devsecops-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.devsecops-node.name
}

resource "aws_eks_node_group" "devsecops" {
  cluster_name    = aws_eks_cluster.devsecops.name
  ami_type        = "ami-0629230e074c580f2"
  instance_types  = "t2.micro"
  node_group_name = "devsecops"
  node_role_arn   = aws_iam_role.devsecops-node.arn
  subnet_ids      = aws_subnet.devsecops[*].id


  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 3
  }

  depends_on = [
    aws_iam_role_policy_attachment.devsecops-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.devsecops-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.devsecops-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
