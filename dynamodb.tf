# Banco NoSQL do oficina-execution-service. O esquema é o mesmo de
# oficina-execution-service/src/main/java/.../adapters/persistence/EsquemaDynamo.java.
#
# Execuções: uma por OS (chave ordemServicoId). O índice status-ordenacao lista a fila
# de execução de um status em ordem de chegada.
resource "aws_dynamodb_table" "execucoes" {
  name         = "oficina-execucoes"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ordemServicoId"

  attribute {
    name = "ordemServicoId"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  attribute {
    name = "ordenacao"
    type = "S"
  }

  global_secondary_index {
    name            = "status-ordenacao"
    hash_key        = "status"
    range_key       = "ordenacao"
    projection_type = "ALL"
  }

  tags = {
    Servico = "oficina-execution-service"
  }
}

# Transactional Outbox: gravada na mesma TransactWriteItems da execução. O índice esparso
# pendentes só contém os eventos com o atributo pendente, removido quando o relay publica.
resource "aws_dynamodb_table" "execution_outbox" {
  name         = "oficina-execution-outbox"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "eventId"

  attribute {
    name = "eventId"
    type = "S"
  }

  attribute {
    name = "pendente"
    type = "S"
  }

  attribute {
    name = "criadoEm"
    type = "S"
  }

  global_secondary_index {
    name            = "pendentes"
    hash_key        = "pendente"
    range_key       = "criadoEm"
    projection_type = "ALL"
  }

  tags = {
    Servico = "oficina-execution-service"
  }
}
