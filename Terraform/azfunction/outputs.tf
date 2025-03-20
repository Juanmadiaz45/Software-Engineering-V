output "function_app_url" {
  value       = azurerm_windows_function_app.wfa.default_hostname
  description = "URL de la Function App"
}

output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "Nombre del grupo de recursos"
}

output "storage_account_name" {
  value       = azurerm_storage_account.sa.name
  description = "Nombre del Storage Account"
}

output "function_app_function_url" {
  value       = azurerm_function_app_function.faf.invocation_url
  description = "URL de la función dentro de la Function App"
}