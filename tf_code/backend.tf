terraform {
  backend "s3" {
    bucket         = "adel-terraform-states"
    key            = "staging/k8s-devops-platform/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
