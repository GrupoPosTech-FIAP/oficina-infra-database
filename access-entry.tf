# Descobre a conta AWS atual
data "aws_caller_identity" "current" {}

locals {
  # No Learner Lab, quem roda o terraform e o kubectl e a role "voclabs".
  # O access entry exige o ARN da ROLE (arn:aws:iam:...:role/voclabs),
  # nao o ARN de sessao STS (arn:aws:sts:...:assumed-role/voclabs/...).
  lab_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/voclabs"
}