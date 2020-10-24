provider "azurerm" {
  version = "=2.20.0"
  # subscription_id = var.subscription_id
  features {}
}

terraform {
  backend "azurerm" {
    storage_account_name = "ktadevstorageaccount"
    container_name       = "ktadevstoragecontainer"
    key                  = "dev.terraform.tfstate"
    access_key = "SPBZvDNRYVm/sT3ODT5Zw2N/ql4VvjVFIvLAXH/g7yKYW3bqcgiwM4gmUd2s/CvNjTce9KvqBgbu8XdAXRTDFw=="
  }
}

# terraform {
#   backend "azurerm" {}
# }