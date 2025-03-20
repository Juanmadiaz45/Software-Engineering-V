variable "location" {
  type        = string
}

variable "resource_group_name" {
  type        = string
}

variable "vnet_name" {
  type        = string
  default     = "myfirtsvmvnet"
}

variable "vnet_address_space" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  type        = string
  default     = "myfirtsvmsubnet"
}

variable "subnet_address_prefix" {
  type        = list(string)
  default     = ["10.0.2.0/24"]
}