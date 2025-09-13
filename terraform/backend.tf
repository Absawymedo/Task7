terraform {
  backend "s3" {
    bucket         = "absawykonectat7"
    key            = "ci/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "tf-lock-ci"
    encrypt        = true
  }
}
