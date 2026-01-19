
#resource "aws_eks_access_policy_association" "admin_user" {
# cluster_name  = aws_eks_cluster.eks.name
#principal_arn = aws_eks_access_entry.admin_user.principal_arn

#policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

#access_scope {
# type = "cluster"
#}
#}
#resource "aws_eks_access_entry" "root_admin" {
# cluster_name  = aws_eks_cluster.eks.name
#principal_arn = "arn:aws:iam::221082201089:root"

#type = "STANDARD"
#}

#resource "aws_eks_access_policy_association" "root_admin" {
#cluster_name  = aws_eks_cluster.eks.name
# principal_arn = aws_eks_access_entry.root_admin.principal_arn

#policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

#access_scope {
# type = "cluster"
#}
#}
