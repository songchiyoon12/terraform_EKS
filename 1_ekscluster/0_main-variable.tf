
variable "aws_region" {
  type = string
  default = "ap-northeast-2"
}


variable "cluster_name" {
  type        = string
  default     = "myeks"
}

variable "cluster_service_ipv4_cidr" {
  type        = string
  default     = "172.20.0.0/16"
}

variable "cluster_version" {
  type = string
  default     = "1.31"
}
variable "cluster_endpoint_private_access" {
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

