resource "aws_efs_file_system" "lambda-backup" {
  encrypted      = true

  tags = {
    Name = "lambda-backup"
  }
}

resource "aws_efs_access_point" "lambda-backup-access-point" {
  file_system_id = aws_efs_file_system.lambda-backup.id
  posix_user {
    uid  = "1001"
    gid  = "1001"
  }
  root_directory {
    path          = "/backup-function"
    creation_info {
      owner_uid   = "1001"
      owner_gid   = "1001"
      permissions = "755"
    }
  }
}

resource "aws_efs_mount_target" "lambda-backup-target" {
  count          = length(var.protected_subnet_ids)
  file_system_id = aws_efs_file_system.lambda-backup.id
  subnet_id      = element(var.protected_subnet_ids, count.index)

  security_groups = [
    var.backup_security_group_id,
  ]
}

resource "aws_efs_file_system" "clamav" {
  encrypted      = true

  tags = {
    Name = "clamav"
  }
}

resource "aws_efs_access_point" "clamav-access-point" {
  file_system_id = aws_efs_file_system.clamav.id
  posix_user {
    uid  = "1001"
    gid  = "1001"
  }
  root_directory {
    path          = "/clamav"
    creation_info {
      owner_uid   = "1001"
      owner_gid   = "1001"
      permissions = "755"
    }
  }
}

resource "aws_efs_mount_target" "clamav-target" {
  count          = length(var.protected_subnet_ids)
  file_system_id = aws_efs_file_system.clamav.id
  subnet_id      = element(var.protected_subnet_ids, count.index)

  security_groups = [
    var.lambda_clamav_security_group_id,
  ]
}
