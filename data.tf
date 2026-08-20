data "terraform_remote_state" "infra" {
  backend = "s3"

  config = {
    bucket = var.infra_state_bucket
    key     = "global/s3/terraform.tfstate"
    region  = "us-east-1"
  }
}