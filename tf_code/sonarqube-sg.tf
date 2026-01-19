resource "aws_security_group" "sonarqube" {
  name        = "${local.env}-sonarqube-sg"
  description = "Allow SonarQube UI"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SonarQube UI - TEMP OPEN FOR DEMO"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.env}-sonarqube-sg"
  }
}
