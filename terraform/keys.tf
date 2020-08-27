# Public keys for logging onto EC2 instances

resource "aws_key_pair" "tmaschler_gfw" {
  key_name   = "tmaschler_gfw"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCGI+i2fgsYXajjgKPPv3prXdEuFEQXrgtM6mVCK6nZeziuSW/3F0Y1JTCPp/SOw0p5I6ila0f1pzofeCeH+0MSwQ4q+tg66a6ZkgV16LWo0VYptBTIbDTUdp/O0KjxCviQLcZByvDd0AJAX81Cu7ChmZen0dq6U3lp9XWCQ/Lt3z2D8avikHvvtc9DZr6AmUD+fGEMBjKJI2KG7OizLJTLB2tvNJ5teEGNRVNI7ZiSgVg98Z0OeOODIM2QuVvU6xb6iCdGKdLRiNGf4Eq4Z71eiph+noaItziABWkiGha4EFbIWf4lKlH45mQn6BYhVtwtLnx6qsVA+PaErJuticnd tmaschler_gfw"
}

resource "aws_key_pair" "jterry_gfw" {
  key_name   = "jterry_gfw"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDD+g/ErUbN+x96CHEyHbTMusZ2drZ2bXMZ8TA5NEM/CasIKjVzPmZQnfn+bxQbJQE8GH3Bihl+PwyMOppUEiMJUcLcSjcjS0lySUX3IYQSYfJ4mru7olD4NGYxbFcsM7GAjQVjYjM/Ye6iYN/ypzm1qI8nMl/JbKMs2N4+b4XbyJYom2QTrtLEEB6QAY4ubwGAyWtKE8s1xdWoxVim1NI4dWcQ1BNTTpTKdbMJQvmA/bWRgGp9zqDJ1ulHcpumRLFmiI2Tu1Ez1NThfJv8xZSjMp/B1SzNr8Xe+1vGYCD/qXlSfv/uKtGPvSZcqjOI60deacWJ1Cj0Fw6iQrTz+pCD jterry_gfw"
}

resource "aws_key_pair" "dmannarino_gfw" {
  key_name   = "dmannarino_gfw"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCLq0/1vhgRfispsHZHrX2H8Mz/HgtTSOiVlMmaUZE0xYPmTBf0cjpHggEN/vwM7FtAkoqozzkdA9PmlBXYye/7orNBGgOR/kXp2ssmyw80inrrCNgd5u6xKWwsydMXJZgvUHWu8PclM3xDNIkFr44ZwpUUJ4xoOzQNOoDjjL6te9rM6ZDXknQLYNf9gm6Isy584TP/kgtUGeS3megv0b+IE187AdLxllPRWCKp8rIWPBFFbP4TBiqWi5WJSJh+r8Z6DjfU/OTPPFgdiuaXjlHr/eGgKDx6merneLmt+rjb/dOxNbQErRzaCY0mZT9umod1vTZJS/4hV31ieXWr+ntF dmannarino_gfw"
}


# Note: Adding new keys will destroy the Bastion host and recreate it with new user data
resource "aws_key_pair" "all" {
  for_each = {
    tmaschler_gfw  = aws_key_pair.tmaschler_gfw.public_key
    jterry_gfw     = aws_key_pair.jterry_gfw.public_key
    dmannarino_gfw = aws_key_pair.dmannarino_gfw.public_key
  }
  key_name   = each.key
  public_key = each.value
}