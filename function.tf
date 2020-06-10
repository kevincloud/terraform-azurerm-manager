resource "azurerm_storage_account" "function-sa" {
    name                     = "${var.identifier}functionsa"
    resource_group_name      = azurerm_resource_group.res-group.name
    location                 = azurerm_resource_group.res-group.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "appserv-plan" {
    name                = "${var.identifier}-functions-service-plan"
    location            = azurerm_resource_group.res-group.location
    resource_group_name = azurerm_resource_group.res-group.name
    kind                = "FunctionApp"

    sku {
        tier = "Dynamic"
        size = "Y1"
    }
}

resource "azurerm_function_app" "function-app" {
    name                       = "${var.identifier}-sentinel-functions"
    location                   = azurerm_resource_group.res-group.location
    resource_group_name        = azurerm_resource_group.res-group.name
    app_service_plan_id        = azurerm_app_service_plan.appserv-plan.id
    storage_account_name       = azurerm_storage_account.function-sa.name
    storage_account_access_key = azurerm_storage_account.function-sa.primary_access_key
    version                    = 3
    app_settings = {
        APP_ACCOUNT_KEY = var.account_key
        APP_IDENTIFIER = var.identifier
    }
}
