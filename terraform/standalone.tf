# We generate certificates outside of AWS and manually registered it with the account.
# We imported the existing certificate into TF state

resource "aws_acm_certificate" "globalforestwatch" {
  domain_name       = "*.globalforestwatch.org"
  validation_method = "DNS"

  tags = merge({ "Name" = "Global Forest Watch Wildcard" },
  local.tags)

  lifecycle {
    create_before_destroy = true
  }
  count = var.environment == "dev" ? 0 : 1
}


# Need to create new private keys outside of TF and AWS
# Note: Adding new keys will destroy the Bastion host and recreate it with new user data
resource "aws_key_pair" "all" {
  for_each = {
    tmaschler_gfw  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCGI+i2fgsYXajjgKPPv3prXdEuFEQXrgtM6mVCK6nZeziuSW/3F0Y1JTCPp/SOw0p5I6ila0f1pzofeCeH+0MSwQ4q+tg66a6ZkgV16LWo0VYptBTIbDTUdp/O0KjxCviQLcZByvDd0AJAX81Cu7ChmZen0dq6U3lp9XWCQ/Lt3z2D8avikHvvtc9DZr6AmUD+fGEMBjKJI2KG7OizLJTLB2tvNJ5teEGNRVNI7ZiSgVg98Z0OeOODIM2QuVvU6xb6iCdGKdLRiNGf4Eq4Z71eiph+noaItziABWkiGha4EFbIWf4lKlH45mQn6BYhVtwtLnx6qsVA+PaErJuticnd tmaschler_gfw",
    jterry_gfw     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDD+g/ErUbN+x96CHEyHbTMusZ2drZ2bXMZ8TA5NEM/CasIKjVzPmZQnfn+bxQbJQE8GH3Bihl+PwyMOppUEiMJUcLcSjcjS0lySUX3IYQSYfJ4mru7olD4NGYxbFcsM7GAjQVjYjM/Ye6iYN/ypzm1qI8nMl/JbKMs2N4+b4XbyJYom2QTrtLEEB6QAY4ubwGAyWtKE8s1xdWoxVim1NI4dWcQ1BNTTpTKdbMJQvmA/bWRgGp9zqDJ1ulHcpumRLFmiI2Tu1Ez1NThfJv8xZSjMp/B1SzNr8Xe+1vGYCD/qXlSfv/uKtGPvSZcqjOI60deacWJ1Cj0Fw6iQrTz+pCD jterry_gfw",
    dmannarino_gfw = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCLq0/1vhgRfispsHZHrX2H8Mz/HgtTSOiVlMmaUZE0xYPmTBf0cjpHggEN/vwM7FtAkoqozzkdA9PmlBXYye/7orNBGgOR/kXp2ssmyw80inrrCNgd5u6xKWwsydMXJZgvUHWu8PclM3xDNIkFr44ZwpUUJ4xoOzQNOoDjjL6te9rM6ZDXknQLYNf9gm6Isy584TP/kgtUGeS3megv0b+IE187AdLxllPRWCKp8rIWPBFFbP4TBiqWi5WJSJh+r8Z6DjfU/OTPPFgdiuaXjlHr/eGgKDx6merneLmt+rjb/dOxNbQErRzaCY0mZT9umod1vTZJS/4hV31ieXWr+ntF dmannarino_gfw"
  }
  key_name   = each.key
  public_key = each.value
}


#
# There is no other place to specify the retention periode for batch log files
#
resource "aws_cloudwatch_log_group" "batch_job" {
  name              = "/aws/batch/job"
  retention_in_days = 30
}


# Not sure what this is for but cannot delete it. So just keep it
resource "aws_iam_service_linked_role" "spot" {
  aws_service_name = "spot.amazonaws.com"
}