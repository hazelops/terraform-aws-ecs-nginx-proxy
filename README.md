# AWS ECS Nginx Proxy Terraform Module

Terraform module for creating an Nginx Proxy container in AWS ECS. This module generates a container definition for use in ECS task definitions.

## Features

-  Secret management via AWS SSM Parameter Store
-  Support for FARGATE and EC2 launch types
-  CloudWatch Logs integration
-  Volume mounting for nginx templates and static files
-  Flexible configuration via environment variables

## Usage Example

```hcl
module "nginx_proxy" {
  source = "github.com/hazelops/terraform-aws-ecs-nginx-proxy"

  env              = "production"
  app_name         = "myapp"
  name             = "nginx-proxy"

  ecs_launch_type  = "FARGATE"
  ecs_network_mode = "awsvpc"

  docker_image_name = "nginx"
  docker_image_tag  = "stable-alpine"

  docker_container_port     = 80
  docker_memory_reservation = 256

  cloudwatch_log_group = "/ecs/myapp/nginx"

  environment = {
    NGINX_HOST = "example.com"
    NGINX_PORT = "80"
  }

  secret_names = [
    "API_KEY",
    "DATABASE_URL"
  ]

  resource_requirements = [
    {
      type  = "VCPU"
      value = "256"
    },
    {
      type  = "MEMORY"
      value = "512"
    }
  ]
}

# Usage in task definition
resource "aws_ecs_task_definition" "app" {
  family                   = "myapp"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    module.nginx_proxy.container_definition,
    # ... other containers
  ])
}
```

## How Secrets Work

The module automatically:
1. Creates parameters in AWS SSM Parameter Store at path: `/{env}/{app_name}/{secret_name}`
2. Builds ARN for each secret
3. Adds secrets to container definition in ECS format

By default, a `PASSWORD` secret is always created. Additional secrets can be specified via `secret_names`.

## Volumes

The module mounts two volumes (when `enabled = true`):

- `nginx-templates` → `/etc/nginx/templates/` - for nginx configuration templates
- `nginx-app` → `/app/` - for application static files

## Container Dependencies

The nginx container waits for the application container (`app_name`) to start before launching, using the `dependsOn` mechanism with `START` condition.

## OpenTofu Compatibility

This module is fully compatible with OpenTofu:

- Tested with: OpenTofu 1.11.1
- Minimum version: OpenTofu >= 1.6.2
- AWS Provider: 6.x (same as Terraform)

The module works with OpenTofu without any modifications. OpenTofu users can use this module exactly as shown in the examples above.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0  |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ssm"></a> [ssm](#module\_ssm) | hazelops/ssm-parameters/aws | ~> 1.1 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Application name used for SSM parameter paths and container dependencies | `string` | n/a | yes |
| <a name="input_cloudwatch_log_group"></a> [cloudwatch\_log\_group](#input\_cloudwatch\_log\_group) | CloudWatch log group name for container logs (empty string disables CloudWatch logging) | `string` | `""` | no |
| <a name="input_docker_container_port"></a> [docker\_container\_port](#input\_docker\_container\_port) | Port on which the nginx container listens | `number` | `80` | no |
| <a name="input_docker_image_name"></a> [docker\_image\_name](#input\_docker\_image\_name) | Docker image name for nginx | `string` | `"nginx"` | no |
| <a name="input_docker_image_tag"></a> [docker\_image\_tag](#input\_docker\_image\_tag) | Docker image tag for nginx | `string` | `"stable-alpine"` | no |
| <a name="input_docker_memory_reservation"></a> [docker\_memory\_reservation](#input\_docker\_memory\_reservation) | Memory reservation for the container in MB | `number` | `128` | no |
| <a name="input_ecs_launch_type"></a> [ecs\_launch\_type](#input\_ecs\_launch\_type) | ECS launch type (FARGATE or EC2) | `string` | n/a | yes |
| <a name="input_ecs_network_mode"></a> [ecs\_network\_mode](#input\_ecs\_network\_mode) | ECS network mode (awsvpc, bridge, or host) | `string` | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Enable or disable the nginx proxy container | `bool` | `true` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment name (dev, production) | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment variables to pass to the container | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Container name for the nginx proxy | `string` | `"nginx"` | no |
| <a name="input_resource_requirements"></a> [resource\_requirements](#input\_resource\_requirements) | Resource requirements for Fargate (list of objects with type and value) | `list(any)` | `[]` | no |
| <a name="input_secret_names"></a> [secret\_names](#input\_secret\_names) | List of additional secret names to load from SSM Parameter Store (PASSWORD is always included) | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_definition"></a> [container\_definition](#output\_container\_definition) | ECS container definition for the nginx proxy container |
<!-- END_TF_DOCS -->

## License

Apache 2.0

