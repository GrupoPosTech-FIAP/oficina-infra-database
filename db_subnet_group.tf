resource "aws_db_subnet_group" "database" {
  name       = "oficina-db-subnet-group"
  subnet_ids = data.terraform_remote_state.infra.outputs.SUBNET_ID
}