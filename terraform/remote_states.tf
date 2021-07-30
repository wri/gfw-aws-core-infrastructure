# NOTE: there is risk of circular imports here and this is generally bad practice
# We use the FW repo to manage 3SC users and this was the easiest way to get their SSH keys on to our bastion host
# The other alternative would be to create a seperate bastion host just for them which is managed inside the FW repo.
data "terraform_remote_state" "fw_core" {
  backend = "s3"
  config = {
    bucket = local.tf_state_bucket
    region = "us-east-1"
    key    = "wri__fw_core_infrastructure.tfstate"
  }
}