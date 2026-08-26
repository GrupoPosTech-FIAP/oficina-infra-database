output "DB_Endpoint" {
  description = "Endpoint do RDS Postgres"
  value       = aws_db_instance.default.address
}

output "DB_Port" {
  description = "Porta do RDS Postgres"
  value       = aws_db_instance.default.port
}

output "DB_Name" {
  description = "Nome do banco de dados"
  value       = aws_db_instance.default.db_name
}

output "DB_Secret_Arn" {
  description = "ARN do segredo no Secrets Manager com usuario/senha do RDS (manage_master_user_password=true). Não é sensível - é só um identificador; quem consome precisa da permissão secretsmanager:GetSecretValue (LabRole já tem)."
  value       = aws_db_instance.default.master_user_secret[0].secret_arn
}
