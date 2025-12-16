output "efs_file_system" {
  value = aws_efs_file_system.pi
}

output "efs_security_group" {
  value = aws_security_group.efs
}

output "efs_mount_target_ids" {
  value = aws_efs_mount_target.pi[*].id
}