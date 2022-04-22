# We generate certificates outside of AWS and manually registered it with the account.
# We imported the existing certificate into TF state
# I suspect ^ is only true of staging/prod, not dev - Daniel

resource "aws_acm_certificate" "globalforestwatch" {
  domain_name       = "*.globalforestwatch.org"
  validation_method = "DNS"

  tags = merge({
    "Name" = "Global Forest Watch Wildcard"
    },
  local.tags)

  lifecycle {
    create_before_destroy = true
  }
  count = 1
}

resource "aws_acm_certificate" "globalforestwatch_new" {
  domain_name       = "*.globalforestwatch.org"
  validation_method = "DNS"

  tags = merge({
    "Name" = "Global Forest Watch Wildcard"
    },
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
    snegusse_gfw   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDHwKzgoKejAQHhT9Uw8WcXoq8e8YkJ9N4L/fCRkNqarvZfn6uo+u4iq5W0UEVOnjBgANCrCtkmV/z6xlZ6P+ncrqJbimYSfNxE5KAkSvfsCKOfxcKI3y3uoM+SSSC61A4IK4/RgckYcR71KZeQ21/2WyPTnqyJSweseDvyp26fAoGcFjErUJdfU/bYC5PkQ6rg3F2yfVufCvRIRVUf5ZM4tFDgGAosut3sB7xjiplz2vEZAmA9l6f3IcKFEFHAHuje+FFy9lLtG/i3PZD3WICrcAboprw42tnPHXqgP++UTYZHknw5DFfZPtcXV+OON97ObdmgRuWLCDbHFpuuvpOjZ8EiBAHL7gNTcrmx38rsHtWD/yIFBuXFkpHKfGPHrXNBYEaQwKnCBhs5GKuFNNkCPx1M1gOlIAuTDowOcvEjULIeCNdrOVVjVVxkcls00/G6bTmmZIZIOz3v3SqtJBp/0id9P8xPVwMeqkVhH7RvGoSPoYgg2FUkvr/vM5owlb0= solomon.negusse@wri.org"

    // TODO: Same keys are also define in the FW Core Infrastructure State. Due to circular dependencies, and TF version conflicts I could not import those keys into this state
    //  we only need the keys here to add them to the bastion host. An alternative would be to create a separate bastion host for 3SC in their repo
    tyeadon_3sc  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEZ2a1o2OQCvScQipFvnQ7OrCxWRx7QwGa76BB6YJ9aex13AANeMXQQ3hLWdKvTA03N47x6CwbwBcFs532Oc0EFjYrFYmt3/ZrUW87OKC0LJz+i9Ap7HfMtJWAKL5HyFWTqL1ohsXrXftdotq54rfJK2xJ+hRsFVKXxd8FFVhPNAN5nV7oVf+7Q9/WnPwXcHJvPQCys6oiDCySk0a9P76sW1vSFghAIokgMsFYK9PE5gLP4wT3G13A+Z+VOZTLzUJHoYRnFK/QPI2P5fAf7vstVYwIdDhw9NwZF2j9bTabQsqJrxVUrqCX2A2xEzLgfbVQm4JG5LWxneLTkzX1vzHr"
    oevans_3sc  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDdy9oatA/nDCdGpBusaK/XiqSWrWSMtVkBQAfIEznZf1vCUsbOrgLQTYJWbuPaHj0IBzZlEeFATLEY04GIYa++t1du1JAIJqd2bhNYrEGYPimkzF11k93UygIuYnDdgJfApwyibdvUj63xtgP/INzUJan2NdgGZ/pg7ZJAbPMZgtE+QO8qFZkHIsnnAyJl+ZyV5SrMjK+5Qxv05TuR+bb1sGg05IW2uqAHdRMZEREfRdDoo1jVU7oIsHbNJQdSvA6kC0NBfIn0M1nb/br6t+Gr7oACzpOs/JKSOinIi0l1pJZ1dDoQTS5ACppUh5MXjgsmGCxYk7pN7x0vTj+bxQBFLbJZklK/dTAPVO8MKIFDHgfnh4LyoEPnOcpkUcmZ3Dxl1PulEYmtQRkOdQPI5jkF2SOT/iJ42UIgMZ1m08ZOT4wf+oKncW9Rb/4uo+PHRddrdBcyS/dZHkLDogvYNpMXpeJyniRHcEsXszv5HPPf88Ka93pj0N1btz0bwgpG8Yc= owen@3s-MacBook-Pro.local"
    gcrosby_3sc  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDlNQHV5VApZuneWtc9m9d7WEUqmfoLWm0John5vRwoPC0GYIU56BH90Yeiw5HkXJsiqnO+WXubFqWylhCRyfckNiTC7sKbpydZHVH4VmvNzOV4z8BXPob1qsnL2d+5eO8U7Sf21jpBQ4HEXgBk4GZ4eRuktM4eYRGsgTRW/FLFUex6c76Nb5va0FakDKXNKiojIoTIjLN0sxKAQtxuJAt4X4Jg6rtd5pS/4l9pH/VPncKcag1tDvx5ytN/4+lb9IZg/8OyG5JZDWaCsvhauJxn+LGP3GtHiEmiu3IMvTwthVWBj1rmFaX/KoOSlQazHlzEREHQ51mb+6MXSwoz+WrqcgkvFLtky0syMRqwjBgCU2IoKS/Cn2+qh7pI0L7ctPb7WjKmQw7vTfQDW3IDPPU2/H2WlJRChrLMWYzFt6oBWKDr4D7YwH89LYsA67rR9xZHY6TgmVexjiXPjnawAqHKEryESqSuNLDWQmNwrGJaWzmf04T3N+5puDIyuhq5MIlbP63mxSXOUEsFIsCKZPkuh/oR105cbSW3U2fZIajuNICXU/YETChn9K7CaR53uqWM7A6vU2VipNb8NJ4v0IP1djECR3/HwrCY+04Fvt/ZOzbvME6cXxfPZLCDRF9Styz4NiTKPQz/6g3Gbl6CF86vdG8uVKmLRUbSBUbEJX02Sw=="
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