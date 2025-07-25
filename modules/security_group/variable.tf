variable "vpc_id" {
  description = "CIDR Range  to be used on VPC"
  type        = string
}

variable "name" {
  description = "Name to be used on security_group"
  type        = string
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks allowed for ingress"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "egress_cidr_blocks" {
  description = "CIDR blocks allowed for egress"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}
