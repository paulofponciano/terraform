resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

resource "aws_instance" "windows-001" {
  ami           = data.aws_ami.windows-ami.image_id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.mykey.key_name
  user_data     = <<EOF
<powershell>
net user ${var.INSTANCE_USERNAME} '${var.INSTANCE_PASSWORD}' /add /y
net localgroup administrators ${var.INSTANCE_USERNAME} /add
Set-TimeZone –Name “E. South America Standard Time”
Rename-Computer -NewName "newhostname"
Start-Sleep -s 5
Restart-Computer
</powershell>
EOF

  tags = {
    Name = "Windows-01"
    Environment = "Dev"
  }
}