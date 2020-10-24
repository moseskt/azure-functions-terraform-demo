output "app_host" {
  value     = azurerm_function_app.functions.default_hostname
  sensitive = false
}

output "site_credentials" {
  value     = azurerm_function_app.functions.site_credential
  sensitive = true
}