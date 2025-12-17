locals {
  secret_names = concat(var.secret_names, [
    "PASSWORD"
  ])

  environment = merge(var.environment,
    {
      ECS_FARGATE = var.ecs_launch_type == "FARGATE" ? "true" : "false"
    }
  )

  # Build ARN from paths for ECS secrets
  ssm_secrets = var.enabled ? [
    for name in local.secret_names : {
      name      = name
      valueFrom = "arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.env}/${var.app_name}/${name}"
    }
  ] : []

  container_definition = {
    name                 = var.name
    image                = "${var.docker_image_name}:${var.docker_image_tag}",
    memoryReservation    = var.docker_memory_reservation,
    essential            = true,
    resourceRequirements = var.resource_requirements

    environment = [for k, v in local.environment : { name = k, value = v }]
    secrets     = local.ssm_secrets

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
      },
      {
        sourceVolume  = "nginx-app",
        containerPath = "/app/"
      }
    ] : []

    logConfiguration = var.cloudwatch_log_group == "" ? {
      logDriver = "json-file"
      options   = {}
      } : {
      logDriver = "awslogs",
      options = {
        awslogs-group         = var.cloudwatch_log_group
        awslogs-region        = data.aws_region.current.region
        awslogs-stream-prefix = var.name
      }
    }
  }
}
