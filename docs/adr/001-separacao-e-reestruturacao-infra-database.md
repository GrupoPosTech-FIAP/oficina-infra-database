# 001 — Separação e reestruturação da infraestrutura de banco de dados

**Status:** Aceita
**Data:** 2024-05-15

## Resumo
Extração da infraestrutura do banco de dados PostgreSQL (RDS) do repositório monolítico
`Tech-Challenge-15SOAT` para um repositório dedicado `oficina-infra-database`, com ajustes
técnicos necessários para que o Terraform consiga provisionar o RDS de forma correta, segura
e integrada com o cluster EKS provisionado pelo `oficina-infra-cluster`.

---

## Problema
O repositório original (`Tech-Challenge-15SOAT`) acumulava em uma única pasta `infra/` todos os
recursos de infraestrutura: rede (VPC), cluster EKS, ECR e banco de dados (RDS). Isso gerava
os seguintes problemas:

- **Acoplamento:** qualquer alteração em qualquer recurso exigia rodar o `terraform apply` de
  toda a infra, aumentando o risco e o tempo de execução.
- **Responsabilidade única violada:** um repositório de aplicação Java não deveria ser responsável
  por provisionar infraestrutura de nuvem.
- **Dificuldade de evolução independente:** cluster e banco possuem ciclos de vida distintos
  (o banco raramente é destruído; o cluster pode ser recriado com mais frequência no Learner Lab).
- **Key de state genérica:** o `backend.tf` usava a key `"global/s3/terraform.tfstate"`,
  sem refletir qual parte da infra estava sendo gerenciada, e sem isolar os states entre repositórios.

Adicionalmente, a configuração original do `db_instance.tf` usava `manage_master_user_password = true`
(delegando a senha ao AWS Secrets Manager), o que era incompatível com a forma que a aplicação
Spring Boot consome a senha — diretamente via Kubernetes Secret.

---

## Proposta técnica
As seguintes alterações foram realizadas neste repositório:

**1. Correção do Remote State (`data.tf`)**
A key do `terraform_remote_state` foi atualizada de `"global/s3/terraform.tfstate"` para
`"cluster/s3/terraform.tfstate"`, alinhando com a key adotada pelo `oficina-infra-cluster`
após sua reestruturação.

**2. Criação do `backend.tf`**
Adicionado o backend S3 com key `"database/s3/terraform.tfstate"` para isolar o state do
banco do state do cluster dentro do mesmo bucket, evitando sobrescrita.

**3. Gerenciamento explícito de senha (`variables.tf` + `db_instance.tf`)**
A variável `db_password` foi adicionada e o `db_instance.tf` foi ajustado para usar
`password = var.db_password` no lugar de `manage_master_user_password = true`.
O banco foi configurado como `publicly_accessible = false`, exposto apenas ao cluster EKS.

**4. Criação do `output.tf`**
Adicionados os outputs `DB_Endpoint`, `DB_Name` e `DB_Username` na raiz do repositório
para que o valor do endpoint possa ser usado como input no deploy da aplicação.

**5. Reescrita do workflow `.github/workflows/deploy.yml`**
- Adicionado `backend-config` no `terraform init` para receber o nome do bucket dinamicamente.
- Adicionado input `DB_PASSWORD` para a senha do banco.
- Adicionado `terraform plan` antes do `apply` para inspeção prévia.
- Adicionado step final para exibir o `DB_Endpoint` ao fim da execução.

**6. Remoção da pasta `infra/`**
A pasta `infra/` continha arquivos órfãos de uma versão anterior (cópias duplicadas de
`variables.tf`, `provider.tf` e um `output.tf` que referenciava recursos inexistentes).
Foi removida pois todos os arquivos relevantes foram migrados e melhorados na raiz.

---

## Impacto esperado

**Ganhos:**
- Ciclos de vida independentes: cluster e banco podem ser provisionados, destruídos e recriados
  de forma isolada, sem risco de afetar o outro.
- State isolado no S3 por responsabilidade (`cluster/` e `database/`), eliminando risco de
  sobrescrita entre repositórios.
- Compatibilidade garantida com o Kubernetes Secret da aplicação Spring Boot, que espera a
  senha diretamente, não via Secrets Manager.
- Visibilidade do `DB_Endpoint` ao final do pipeline, facilitando o próximo passo de deploy
  da aplicação.

**Riscos e restrições:**
- A senha do banco (`db_password`) precisa ser consistente com o GitHub Secret `RDS_PASSWORD`
  do repositório da aplicação. Uma divergência impede a conexão do pod ao banco.
- A ordem de provisionamento é obrigatória: `oficina-infra-cluster` → `oficina-infra-database`
  → deploy da aplicação.
- As credenciais do Learner Lab expiram em ~4h, exigindo atualização manual dos secrets de
  AWS antes de cada execução do pipeline.

---

## Alternativas consideradas

- **Manter tudo em um único repositório:** descartado pela violação do princípio de
  responsabilidade única e dificuldade de evolução independente dos componentes.
- **Usar `manage_master_user_password = true` + integração com Secrets Manager:**
  descartado pela complexidade adicional e incompatibilidade com o modelo atual de injeção
  de senha via Kubernetes Secret.
- **Usar `publicly_accessible = true` permanentemente:** descartado por expor o banco à
  internet sem necessidade. Aceito apenas como configuração temporária para testes locais
  via DBeaver.

---

## Pontos em aberto
- Avaliar a viabilidade de automatizar a cadeia de deploy entre os três repositórios via
  `repository_dispatch` do GitHub Actions, passando os outputs automaticamente entre os
  pipelines.
- Considerar armazenar a `db_password` como GitHub Secret permanente (não como input manual
  do workflow), reduzindo fricção no dia a dia.
- Avaliar migrar para `manage_master_user_password = true` + adaptação da aplicação para
  consumir o Secrets Manager, eliminando o tráfego de senha em texto pela pipeline.
