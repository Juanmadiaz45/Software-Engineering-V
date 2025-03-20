variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "name_function" {
  type        = string
  description = "Nombre de la Function App y recursos asociados"
}

variable "location" {
  type        = string
  default     = "West Europe"
  description = "Región de Azure donde se crearán los recursos"
}