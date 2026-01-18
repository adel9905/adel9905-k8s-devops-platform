########################################
# IAM ROLE FOR JENKINS (EC2)
########################################

resource "aws_iam_role" "jenkins" {
  name = "${local.env}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

########################################
# IAM POLICIES FOR JENKINS
########################################

resource "aws_iam_role_policy_attachment" "jenkins_ecr" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "jenkins_cloudwatch" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

########################################
# INSTANCE PROFILE (REQUIRED FOR EC2)
########################################

resource "aws_iam_instance_profile" "jenkins" {
  name = "${local.env}-jenkins-instance-profile"
  role = aws_iam_role.jenkins.name
}

########################################
# EKS ACCESS FOR JENKINS (NO aws-auth)
########################################

resource "aws_eks_access_entry" "jenkins" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = aws_iam_role.jenkins.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "jenkins" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = aws_iam_role.jenkins.arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
