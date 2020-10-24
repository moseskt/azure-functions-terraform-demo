resource "azurerm_resource_group" "rg" {
    name = "${var.prefix}-${var.environment}"
    location = var.location
}

# The ap insights instance that will be used to monitor the app
resource "azurerm_application_insights" "appmonitor" {
  name                = "appmonitor"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

# The function app that will run the dotnet app by ingesting the zip from the build stage
resource "azurerm_storage_account" "storage" {
    name = random_string.storage_name.result
    resource_group_name = azurerm_resource_group.rg.name
    location = var.location
    account_tier = "Standard"
    account_replication_type = "LRS"
}

resource "azurerm_storage_container" "deployments" {
    name = "function-releases"
    storage_account_name = azurerm_storage_account.storage.name
    container_access_type = "private"
}

resource "azurerm_storage_blob" "appcode" {
    name = "functionapp.zip"
    storage_account_name = azurerm_storage_account.storage.name
    storage_container_name = azurerm_storage_container.deployments.name
    type = "Block"
    source = var.functionapp
}

data "azurerm_storage_account_sas" "sas" {
    connection_string = azurerm_storage_account.storage.primary_connection_string
    https_only = true
    start = "2020-10-06"
    expiry = "2022-12-31"
    resource_types {
        object = true
        container = false
        service = false
    }
    services {
        blob = true
        queue = false
        table = false
        file = false
    }
    permissions {
        read = true
        write = false
        delete = false
        list = false
        add = false
        create = false
        update = false
        process = false
    }
}

resource "azurerm_app_service_plan" "asp" {
    name = "${var.prefix}-plan"
    resource_group_name = azurerm_resource_group.rg.name
    location = var.location
    kind = "FunctionApp"
    sku {
        tier = "Dynamic"
        size = "Y1"
    }
}

resource "azurerm_function_app" "functions" {
    name = "${var.prefix}-${var.environment}-function"
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name
    app_service_plan_id = azurerm_app_service_plan.asp.id
    # storage_connection_string = azurerm_storage_account.storage.primary_connection_string
    storage_account_name = azurerm_storage_account.storage.name
    storage_account_access_key = azurerm_storage_account.storage.primary_access_key
    version = "~2"

    app_settings = {
        https_only = true
        FUNCTIONS_WORKER_RUNTIME = "dotnet"
        WEBSITE_NODE_DEFAULT_VERSION = "~10"
        FUNCTION_APP_EDIT_MODE = "readonly"
        APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.appmonitor.instrumentation_key
        HASH = base64encode(filesha256(var.functionapp))
        WEBSITE_RUN_FROM_PACKAGE = "https://${azurerm_storage_account.storage.name}.blob.core.windows.net/${azurerm_storage_container.deployments.name}/${azurerm_storage_blob.appcode.name}${data.azurerm_storage_account_sas.sas.sas}"
    }

    site_config {
        use_32_bit_worker_process = true
    }
}

# The storage account in which the blob test data will be stored. Access should be restricted
resource "azurerm_storage_account" "priv_storage" {
  name = random_string.priv_storage_name.result
  resource_group_name = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["100.0.0.1"]
    # virtual_network_subnet_ids = [azurerm_subnet.example.id]
  }

  tags = {
    environment = "dev"
  }
}

# resource "azurerm_storage_container" "container_yemablobhu" {
#   name                  = "container-yemablobhu"
#   storage_account_name  = azurerm_storage_account.priv_storage.name
#   container_access_type = "private"
# }