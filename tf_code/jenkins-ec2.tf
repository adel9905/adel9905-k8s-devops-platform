resource "aws_instance" "jenkins" {
  ami                         = "ami-0f5ee92e2d63afc18" # Amazon Linux 2023 ap-south-1
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.public_az1.id
  vpc_security_group_ids      = [aws_security_group.jenkins.id]
  iam_instance_profile        = aws_iam_instance_profile.jenkins.name
  associate_public_ip_address = true
  key_name                    = "jenkins-key" # must exist

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y java-21-amazon-corretto
              wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
              dnf install -y jenkins
              systemctl enable jenkins
              systemctl start jenkins
              EOF

  tags = {
    Name = "${local.env}-jenkins"
  }
}