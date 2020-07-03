## Requirements

| Name | Version |
|------|---------|
| terraform | >=0.12.26 |
| aws | ~> 2.56.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.56.0 |
| local | n/a |
| template | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| application | Name of the current application | `string` | `"gfw-aws-core-infrastructure"` | no |
| aws\_region | A valid AWS region to configure the underlying AWS SDK. | `string` | `"us-east-1"` | no |
| dev\_account\_number | Account number of production account | `string` | `"563860007740"` | no |
| dynamo\_db\_lock\_table\_name | Name of the lock table in Dynamo DB | `string` | `"aws-locks"` | no |
| environment | An environment namespace for the infrastructure. | `string` | n/a | yes |
| gfw\_api\_token | Access token for the GFW/RW API. | `string` | n/a | yes |
| log\_retention\_period | n/a | `number` | n/a | yes |
| production\_account\_number | Account number of production account | `string` | `"401951483516"` | no |
| project | A project namespace for the infrastructure. | `string` | `"Global Forest Watch"` | no |
| rds\_backup\_retention\_period | n/a | `number` | n/a | yes |
| rds\_instance\_class | n/a | `string` | n/a | yes |
| rds\_password | n/a | `string` | n/a | yes |
| rds\_password\_ro | n/a | `string` | n/a | yes |
| slack\_data\_updates\_hook | Hook for Slack data-updates channel | `string` | n/a | yes |
| staging\_account\_number | Account number of production account | `string` | `"274931322839"` | no |

## Outputs

| Name | Description |
|------|-------------|
| account\_id | n/a |
| acm\_certificate | n/a |
| aurora\_cluster\_instance\_class | n/a |
| bastion\_hostname | n/a |
| cidr\_block | n/a |
| data-lake\_bucket | n/a |
| default\_security\_group\_id | n/a |
| emr\_instance\_profile\_name | n/a |
| emr\_service\_role\_name | n/a |
| environment | Environment of current state. |
| iam\_policy\_s3\_write\_data-lake\_arn | n/a |
| iam\_policy\_s3\_write\_pipelines\_arn | n/a |
| key\_pair\_tmaschler\_gfw | n/a |
| nat\_gateway\_ips | n/a |
| pipelines\_bucket | n/a |
| postgresql\_security\_group\_id | Security group ID to access postgresql database |
| private\_subnet\_ids | n/a |
| public\_subnet\_ids | n/a |
| secrets\_postgresql-reader\_arn | n/a |
| secrets\_postgresql-reader\_name | n/a |
| secrets\_postgresql-reader\_policy\_arn | n/a |
| secrets\_postgresql-writer\_arn | n/a |
| secrets\_postgresql-writer\_name | n/a |
| secrets\_postgresql-writer\_policy\_arn | n/a |
| secrets\_read-gfw-api-token\_arn | n/a |
| secrets\_read-gfw-api-token\_policy\_arn | n/a |
| secrets\_read-slack-gfw-sync\_policy\_arn | n/a |
| secrets\_read-slack\_gfw\_sync\_arn | n/a |
| tags | n/a |
| vpc\_id | n/a |

