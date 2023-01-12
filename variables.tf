variable "vpc_id" {
  description = "The ID of the VPC in which the endpoint will be used"
  type        = string
}

variable "subnet_ids" {
  description = "The ID of the VPC in which the endpoint will be used"
  type        = list(string)
}

variable "env" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "project_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}
variable "service_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "target_group_arn" {
  description = "Name to be used on all the resources as identifier"
  type        = list(string)
}

variable "region" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "ecs_task_cpu" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "ecs_task_mem" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "parameter" {
  description = "Name to be used on all the resources as identifier"
  type        = bool
  default     = false
}

variable "assign_public_ip" {
  description = "Name to be used on all the resources as identifier"
  type        = bool
  default     = false
}

variable "parameter_path" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "ecs_task_count" {
  description = "Name to be used on all the resources as identifier"
  type        = number
}

variable "sg_ingress" {
  description = "The ID of the VPC in which the endpoint will be used"
  type        = list(string)
  default     = null
}

variable "cidr_ingress" {
  description = "The ID of the VPC in which the endpoint will be used"
  type        = list(string)
  default     = null
}

variable "retention_in_days" {
  description = "Name to be used on all the resources as identifier"
  type        = number
  default     = 7
}
