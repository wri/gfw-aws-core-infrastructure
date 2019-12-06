# GFW AWS Core Infrastructure

This repo describes GFW's core infrastructure on AWS using Terraform framework.

GFW has three deployment environments
- dev
- staging
- production

Each environment has its own terraform backend.
Other repos can access state of core infrastructure and build on top of it.

## Prerequisites

This repo expects environment to be specified in environment variable `ENV`. If `ENV` is not set, default is `dev`.

You will need to have AWS credentials for the different environments stored in your ~/.aws folder.
Profile names must be
- gfw-dev
- gfw-staging
- gfw-production
respectively. 


## Run

Terraform is executed inside a Docker container.

The following commands are currently supported
- init
- fmt
- plan
- apply
- destroy

To execute commands first build your image (you only need to do that once)

```bash
docker-compose build
```
Than run your command like this:

```bash
docker-compose run --rm terraform <cmd>
```

Always run `plan` before running `apply` and make sure you are working in the right environment.

## Reference core infrastructure in other repositories

You can reference infrastructure defined in this repository and exposed as outputs in other modules

```hcl-terraform
locals {
  bucket_suffix   = var.environment == "production" ? "" : "-${var.environment}"
  tf_state_bucket = "gfw-terraform${local.bucket_suffix}"
}

data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = local.tf_state_bucket
    region = "us-east-1"
    key = "website.tfstate"
  }
}

resource "aws_lambda_function" "default" {
  
  ...

  environment {
    variables = {
      ENVIRONMENT = data.terraform_remote_state.core.outputs.environment
      S3_BUCKET   = data.terraform_remote_state.core.outputs.bootstrap.state_bucket
    }
  }
}
```