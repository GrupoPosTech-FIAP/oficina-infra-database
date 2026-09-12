variable "infra_state_bucket" {
  type        = string
  description = "Nome do bucket S3 onde está o remote state da infra do cluster (oficina-infra-cluster)"
}

variable "db_password" {
  type        = string
  description = "Senha master do RDS PostgreSQL (8-128 chars, sem / @ \" nem espaço)"
  sensitive   = true
}

variable "lambda_security_group_id" {
  type        = string
  description = "SG da Lambda auth-handler (oficina-auth-gateway), liberado para acessar o RDS na porta 5432. Opcional: deixe vazio se o auth-gateway ainda não existir."
  default     = ""
}
