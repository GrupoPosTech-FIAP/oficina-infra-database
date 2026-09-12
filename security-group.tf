# Security Group do RDS: controla QUEM pode falar com o banco.
resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Permite acesso ao RDS PostgreSQL a partir dos nos do EKS"
  vpc_id      = data.terraform_remote_state.infra.outputs.VPC_ID

  # Entrada: porta 5432 (PostgreSQL) SOMENTE vinda do Security Group do cluster EKS
  # e, opcionalmente, do SG da Lambda auth-handler (oficina-auth-gateway).
  # Nao usamos cidr_blocks aqui de proposito: assim o banco nao fica aberto para a
  # internet, so quem estiver nesses SGs consegue alcancar.
  ingress {
    description = "PostgreSQL vindo dos nos do EKS e da Lambda auth-handler"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = compact([
      data.terraform_remote_state.infra.outputs.EKS_Security_Group_Id,
      var.lambda_security_group_id,
    ])
  }

  # Saida liberada (padrao).
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = data.terraform_remote_state.infra.outputs.Tags
}
