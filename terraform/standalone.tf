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
  count = 1
}


# Need to create new private keys outside of TF and AWS
# Note: Adding new keys will destroy the Bastion host and recreate it with new user data
resource "aws_key_pair" "all" {
  for_each = {
    tmaschler_gfw  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCGI+i2fgsYXajjgKPPv3prXdEuFEQXrgtM6mVCK6nZeziuSW/3F0Y1JTCPp/SOw0p5I6ila0f1pzofeCeH+0MSwQ4q+tg66a6ZkgV16LWo0VYptBTIbDTUdp/O0KjxCviQLcZByvDd0AJAX81Cu7ChmZen0dq6U3lp9XWCQ/Lt3z2D8avikHvvtc9DZr6AmUD+fGEMBjKJI2KG7OizLJTLB2tvNJ5teEGNRVNI7ZiSgVg98Z0OeOODIM2QuVvU6xb6iCdGKdLRiNGf4Eq4Z71eiph+noaItziABWkiGha4EFbIWf4lKlH45mQn6BYhVtwtLnx6qsVA+PaErJuticnd tmaschler_gfw",
    jterry_gfw     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCOGcXvYQel176C7gXPPsz8/tOotAJ8yfj4I2e1Uw0KMLgMao/9Yl9DZg9obBO7nG1DiDW9YUt2hpQkB2PpzP5N9yMriL4WXEhLroCWKj/vljRIDZjS3ZG+pPLs2Li9eFLDc0WGb9D+dxVG7Emwg8O/mTVbaAdklC4D1cwKQx7V7kU19K4jTTCA7aqagtI7X6FNh0fJGfVz0aQ01ECZmUNCkVZy+LYhk2wxSDuXV9DIha0akPXZCWqOtICPln+tquM9befLevCcuDpwVOkh1wrAP7EkRQtL8x8lIadenQpHgXoeoNGGp7x10Dywlw2u6Hm4b0mGITu4P1JTf0O2mmDd jterry_gfw",
    dmannarino_gfw = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCLq0/1vhgRfispsHZHrX2H8Mz/HgtTSOiVlMmaUZE0xYPmTBf0cjpHggEN/vwM7FtAkoqozzkdA9PmlBXYye/7orNBGgOR/kXp2ssmyw80inrrCNgd5u6xKWwsydMXJZgvUHWu8PclM3xDNIkFr44ZwpUUJ4xoOzQNOoDjjL6te9rM6ZDXknQLYNf9gm6Isy584TP/kgtUGeS3megv0b+IE187AdLxllPRWCKp8rIWPBFFbP4TBiqWi5WJSJh+r8Z6DjfU/OTPPFgdiuaXjlHr/eGgKDx6merneLmt+rjb/dOxNbQErRzaCY0mZT9umod1vTZJS/4hV31ieXWr+ntF dmannarino_gfw",
    snegusse       = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDHwKzgoKejAQHhT9Uw8WcXoq8e8YkJ9N4L/fCRkNqarvZfn6uo+u4iq5W0UEVOnjBgANCrCtkmV/z6xlZ6P+ncrqJbimYSfNxE5KAkSvfsCKOfxcKI3y3uoM+SSSC61A4IK4/RgckYcR71KZeQ21/2WyPTnqyJSweseDvyp26fAoGcFjErUJdfU/bYC5PkQ6rg3F2yfVufCvRIRVUf5ZM4tFDgGAosut3sB7xjiplz2vEZAmA9l6f3IcKFEFHAHuje+FFy9lLtG/i3PZD3WICrcAboprw42tnPHXqgP++UTYZHknw5DFfZPtcXV+OON97ObdmgRuWLCDbHFpuuvpOjZ8EiBAHL7gNTcrmx38rsHtWD/yIFBuXFkpHKfGPHrXNBYEaQwKnCBhs5GKuFNNkCPx1M1gOlIAuTDowOcvEjULIeCNdrOVVjVVxkcls00/G6bTmmZIZIOz3v3SqtJBp/0id9P8xPVwMeqkVhH7RvGoSPoYgg2FUkvr/vM5owlb0= solomon.negusse@wri.org"
  }
  key_name   = each.key
  public_key = each.value
}


#
# There is no other place to specify the retention period for batch log files
#
resource "aws_cloudwatch_log_group" "batch_job" {
  name              = "/aws/batch/job"
  retention_in_days = 30
}

