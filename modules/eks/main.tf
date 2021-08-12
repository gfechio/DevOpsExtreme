provider aws {}

resource "aws_security_group" "security_group_eks_cluster" {
  name        = "terraform-eks-cluster"
  description = "cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-sg"
  }
}

resource "aws_iam_role" "eks_cluster_roles" {
  name = "terraform-eks-cluster"

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
  tags = {
    tag-key = "sts"
  }
  depends_on = [aws_security_group.aws_security_group]
}

resource "aws_iam_role_policy_attachment" "cluster-EKSpolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_roles.name
}

resource "aws_iam_role_policy_attachment" "cluster-EKSsvcpolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_roles.name
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_roles.arn

  vpc_config {
    security_group_ids = [aws_security_group.security_group_eks_cluster.id]
    subnet_ids         = var.private_subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster-EKSpolicy,
    aws_iam_role_policy_attachment.cluster-EKSsvcpolicy,
  ]
}

resource "aws_iam_role" "node" {
  name = "terraform-eks-node"

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

depends_on = [aws_eks_cluster.eks_cluster]

}


resource "aws_iam_policy" "ALBIngressControllerIAMPolicy" {
  name   = "ALBIngressControllerIAMPolicy"
  policy = file("${path.module}/files/iam-policy.json")
  depends_on = [aws_eks_cluster.eks_clusters]
}

resource "aws_iam_role_policy_attachment" "node_EKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
  depends_on = [aws_eks_cluster.eks_clusters]
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
  depends_on = [aws_eks_cluster.eks_clusters]
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
  depends_on = [aws_eks_cluster.eks_clusters]
}


resource "aws_iam_role_policy_attachment" "node_ALBIngressControllerIAMPolicy" {
  policy_arn = aws_iam_policy.ALBIngressControllerIAMPolicy.arn
  role       = aws_iam_role.node.name
}

resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "workers"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_EKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.node_ALBIngressControllerIAMPolicy,
  ]
}


