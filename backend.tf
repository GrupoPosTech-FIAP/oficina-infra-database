terraform {
  backend "s3" {
    key     = "database/s3/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
