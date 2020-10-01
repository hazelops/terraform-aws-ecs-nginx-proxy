data "aws_region" "current" {}

locals {
  secret_names = concat(var.secret_names, [
    "PASSWORD"
  ])

  environment = merge(var.environment,
    {
      ECS_FARGATE = var.ecs_launch_type == "FARGATE" ? "true" : "false"
    }
  )

  container_definition = {
    name                 = var.name
    image                = "${var.docker_image_name}:${var.docker_image_tag}",
    memoryReservation    = var.docker_memory_reservation,
    essential            = true,
    resourceRequirements = var.resource_requirements

    environment = [for k, v in local.environment : { name = k, value = v }]
    secrets     = module.ssm.secrets

    portMappings = [{
      containerPort = var.docker_container_port,
      // In case of bridge an host use a dynamic port (0)
      hostPort = var.ecs_network_mode == "awsvpc" ? var.docker_container_port : 0
    }]

    // This is used to make sure the app container has started before starting proxy (for nginx config to be copied to a volume and for port reachibility)
    dependsOn = [{
      containerName = var.app_name,
      condition     = "START"
    }],

    // This is used to map nginx config template from a volume (which can be created by the original app container)
    mountPoints = var.enabled ? [
      {
        sourceVolume  = "nginx-templates",
        containerPath = "/etc/nginx/templates/"
      }
    ] : []

    logConfiguration = var.cloudwatch_log_group == "" ? {
      logDriver = "json-file"
      options   = {}
      } : {
      logDriver = "awslogs",
      options = {
        awslogs-group         = var.cloudwatch_log_group
        awslogs-region        = data.aws_region.current.name
        awslogs-stream-prefix = var.name
      }
    }
  }
}

module "ssm" {
  source   = "hazelops/ssm-secrets/aws"
  version  = "~> 1.0"
  env      = var.env
  app_name = var.app_name
  names    = var.enabled ? local.secret_names : []
}
