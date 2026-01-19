resource "aws_instance" "sonarqube" {
  ami                         = "ami-03f4878755434977f" # Ubuntu 22.04 ap-south-1
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.private_az1.id
  vpc_security_group_ids      = [aws_security_group.sonarqube.id]
  iam_instance_profile        = aws_iam_instance_profile.sonarqube.name
  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y openjdk-17-jdk unzip postgresql
              systemctl enable postgresql
              systemctl start postgresql
              EOF

  tags = {
    Name = "${local.env}-sonarqube"
  }
}
