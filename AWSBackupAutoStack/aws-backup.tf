# CRIAÇÃO KMS KEY
resource "aws_kms_key" "backup_kms_key" {
  description             = join("-", [var.customer_env, "KMS-Key-Backup", var.AWS_REGION])
  deletion_window_in_days = 10
}

# CRIAÇÃO BACKUP VAULT
resource "aws_backup_vault" "backup_vault" {
  name        = join("-", [var.customer_env, "backup-vault", var.AWS_REGION])
  kms_key_arn = aws_kms_key.backup_kms_key.arn
}

# CARREGANDO VALOR POLICY
data "aws_iam_policy_document" "backup_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }

  version = "2012-10-17"
}

# CARREGANDO VALOR POLICY
data "aws_iam_policy" "backup_iam_policy" {
  name = "AWSBackupServiceRolePolicyForBackup"
}

# CRIAÇÃO ROLE PARA BACKUP
resource "aws_iam_role" "backup_role" {
  name               = join("-", [var.customer_env, "backup-role", var.AWS_REGION])
  assume_role_policy = data.aws_iam_policy_document.backup_policy_document.json
}

# ATTACH ROLE
resource "aws_iam_role_policy_attachment" "backup_policy_attach" {
  policy_arn = data.aws_iam_policy.backup_iam_policy.arn
  role       = aws_iam_role.backup_role.name
}

# CRIAÇÃO PLANO DE BACKUP
resource "aws_backup_plan" "main-backup-plan" {
  name = join("-", [var.customer_env, "backup-plan", var.AWS_REGION])

  # REGRA DE BACKUP DIÁRIO
  rule {
    completion_window = 300
    rule_name         = "DailyBackups"
    schedule          = "cron(0 5 ? * * *)"
    start_window      = 120
    target_vault_name = join("-", [var.customer_env, "backup-vault", var.AWS_REGION])

    lifecycle {
      cold_storage_after = 0
      delete_after       = 7
    }
  }

  # REGRA DE BACKUP SEMANAL
  rule {
    completion_window = 300
    rule_name         = "WeeklyBackups"
    schedule          = "cron(0 5 ? * 1 *)"
    start_window      = 120
    target_vault_name = join("-", [var.customer_env, "backup-vault", var.AWS_REGION])

    lifecycle {
      cold_storage_after = 0
      delete_after       = 14
    }
  }

  # REGRA DE BACKUP MENSAL
  rule {
    completion_window = 300
    rule_name         = "MonthlyBackups"
    schedule          = "cron(0 5 1 * ? *)"
    start_window      = 120
    target_vault_name = join("-", [var.customer_env, "backup-vault", var.AWS_REGION])

    lifecycle {
      cold_storage_after = 0
      delete_after       = 90
    }
  }

  depends_on = [
    aws_backup_vault.backup_vault
  ]
}

# GATILHO DE BACKUP
resource "aws_backup_selection" "backup-selection" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "Backup-yes"
  plan_id      = aws_backup_plan.main-backup-plan.id

  resources = [
    "arn:aws:ec2:*:*:volume/*",
    "arn:aws:elasticfilesystem:*:*:file-system/*",
    "arn:aws:rds:*:*:db:*"
  ]

  condition {
    string_equals {
      key   = "aws:ResourceTag/Backup"
      value = "yes"
    }
  }
}