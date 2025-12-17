variable "env" {
  description = "Environment name (dev, production)"
  type        = string
}

variable "name" {
  description = "Container name for the nginx proxy"
  type        = string
  default     = "nginx"
}

variable "app_name" {
  description = "Application name used for SSM parameter paths and container dependencies"
  type        = string
}

variable "environment" {
  description = "Environment variables to pass to the container"
  type        = map(string)
  default     = {}
}

variable "secret_names" {
  description = "List of additional secret names to load from SSM Parameter Store (PASSWORD is always included)"
  type        = list(string)
  default     = []
}

variable "docker_image_name" {
  description = "Docker image name for nginx"
  type        = string
  default     = "nginx"
}

variable "docker_image_tag" {
  description = "Docker image tag for nginx"
  type        = string
  default     = "stable-alpine"
}

variable "ecs_launch_type" {
  description = "ECS launch type (FARGATE or EC2)"
  type        = string
}

variable "cloudwatch_log_group" {
  description = "CloudWatch log group name for container logs (empty string disables CloudWatch logging)"
  type        = string
  default     = ""
}

variable "docker_container_port" {
  description = "Port on which the nginx container listens"
  type        = number
  default     = 80
}

variable "ecs_network_mode" {
  description = "ECS network mode (awsvpc, bridge, or host)"
  type        = string
}

variable "resource_requirements" {
  description = "Resource requirements for Fargate (list of objects with type and value)"
  type        = list(any)
  default     = []
}

variable "docker_memory_reservation" {
  description = "Memory reservation for the container in MB"
  type        = number
  default     = 128
}

variable "enabled" {
  description = "Enable or disable the nginx proxy container"
  type        = bool
  default     = true
}
