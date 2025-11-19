output "efs_file_system" {
  value = aws_efs_file_system.pi
}

output "efs_security_group" {
  value = aws_security_group.efs
}
