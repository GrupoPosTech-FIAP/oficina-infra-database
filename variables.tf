variable "infra_state_bucket" {
  type        = string
  description = "Nome do bucket S3 onde está o remote state da infra do cluster (oficina-infra-cluster)"
}

variable "db_password" {
  type        = string
  description = "Senha master do RDS PostgreSQL (8-128 chars, sem / @ \" nem espaço)"
  sensitive   = true
}