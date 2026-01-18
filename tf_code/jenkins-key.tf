########################################
# SSH KEY FOR JENKINS EC2
########################################

resource "tls_private_key" "jenkins" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "jenkins" {
  key_name   = "jenkins-key"
  public_key = tls_private_key.jenkins.public_key_openssh
}

# Save private key locally (DO NOT COMMIT)
resource "local_file" "jenkins_private_key" {
  filename        = "${path.module}/jenkins-key.pem"
  content         = tls_private_key.jenkins.private_key_pem
  file_permission = "0400"
}
