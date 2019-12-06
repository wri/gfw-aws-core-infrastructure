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

```
docker-compose build
```
Than run your command like this:

```
docker-compose run --rm terraform <cmd>
```

Always run `plan` before running `apply` and make sure you are working in the right environment.