# REGIAO DO PROVISIONAMENTO
variable "AWS_REGION" {
  default = "us-east-1"
}

# INFORMAR AQUI IDENTIFICACAO DO AMBIENTE - SERA UTILIZADO PARA IDENTIFICAR VAULT, BACKUP PLAN, KMS KEY
variable "customer_env" {
  default = "ENV_NAME"
}

# 5AM (UTC) - 02AM (UTC-3)
# Backup diário, retenção 7 dias
# Backup semanal, todo domingo, retenção 14 dias (duas semanas)
# Backup mensal, todo dia 1, retenção 90 dias (3 meses)