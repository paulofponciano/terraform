resource "aws_key_pair" "sshkey" {
  key_name   = "sshkey"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

resource "aws_instance" "example" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.sshkey.key_name

  provisioner "file" {
    source      = "script-data.sh"
    destination = "/tmp/script-data.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script-data.sh",
      "sudo sed -i -e 's/\r$//' /tmp/script-data.sh",  # Remove the spurious CR characters.
      "sudo /tmp/script-data.sh",
    ]
  }
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = var.INSTANCE_USERNAME
    private_key = file(var.PATH_TO_PRIVATE_KEY)
  }
}