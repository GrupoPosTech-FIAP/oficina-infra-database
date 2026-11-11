output "DB_Endpoint" {
  description = "Endpoint do RDS — use como input no deploy da aplicação (Tech-Challenge-15SOAT)"
  value       = aws_db_instance.default.address
}

output "DB_Name" {
  description = "Nome do banco de dados criado no RDS"
  value       = aws_db_instance.default.db_name
}

output "DB_Username" {
  description = "Usuário master do RDS"
  value       = aws_db_instance.default.username
}

output "DynamoDB_Tabelas_Execution" {
  description = "Tabelas DynamoDB do oficina-execution-service"
  value       = [aws_dynamodb_table.execucoes.name, aws_dynamodb_table.execution_outbox.name]
}
