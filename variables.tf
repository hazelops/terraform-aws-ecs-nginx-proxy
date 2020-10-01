variable "env" {
}

variable "name" {
  default = "nginx"
}

variable "app_name" {
  type = string
}


variable "environment" {
  type    = map(string)
  default = {}
}

variable "secret_names" {
  type    = list(string)
  default = []
}

//variable "ecs_cluster" {
//  type = string
//}

variable "docker_image_name" {
  type    = string
  default = "nginx"
}

variable "docker_image_tag" {
  type    = string
  default = "1.19.2-alpine"
}

variable "ecs_launch_type" {

}

variable "cloudwatch_log_group" {
  default = ""
}

variable "docker_container_port" {
  default = 80
}

variable "ecs_network_mode" {
}

variable "resource_requirements" {
  default = []
}

variable "docker_memory_reservation" {
  default = 128
}


variable "enabled" {
  default = true
}
