data "aws_subnet" "private_subnet" {
  id = var.application_subnet_ids[0]
}

resource "aws_efs_file_system" "pi" {
  creation_token = "panintelligence-efs-${var.deployment_name}"

  tags = {
    Name = "${var.deployment_name}-efs"
  }
}

resource "aws_security_group" "efs" {
  name        = "${var.deployment_name}-efs"
  description = "Security group for ${var.deployment_name} services accessing efs mount points"
  vpc_id      = data.aws_subnet.private_subnet.vpc_id

  tags = {
    Name = "${var.deployment_name}-efs"
  }
}

resource "aws_efs_mount_target" "pi_a" {
  for_each       = toset(var.application_subnet_ids)
  file_system_id = aws_efs_file_system.pi.id
  subnet_id      = each.key

  security_groups = [aws_security_group.efs.id]
}


data "aws_iam_policy_document" "backup_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "pi_efs_backup" {
  name               = "${var.deployment_name}-efs-backup"
  assume_role_policy = data.aws_iam_policy_document.backup_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "pi_efs_backup" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.pi_efs_backup.name
}


resource "aws_backup_vault" "pi_efs_backup" {
  name          = "${var.deployment_name}-efs-backup"
  force_destroy = var.efs_backup_force_destroy
}


resource "aws_backup_plan" "pi_efs_backup" {
  name = "${var.deployment_name}-efs-backup"

  rule {
    rule_name         = "pi_efs_backup"
    target_vault_name = aws_backup_vault.pi_efs_backup.name
    schedule          = var.efs_backup_vault_cron
  }
}

resource "aws_backup_selection" "pi" {
  iam_role_arn = aws_iam_role.pi_efs_backup.arn
  name         = "panintelligence_efs_backup_${var.deployment_name}"
  plan_id      = aws_backup_plan.pi_efs_backup.id

  resources = [
    aws_efs_file_system.pi.arn
  ]

}