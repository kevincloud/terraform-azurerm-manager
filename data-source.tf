resource "azurerm_cosmosdb_account" "cosmosdb" {
    name                = "${var.identifier}-cosmos-db"
    location            = azurerm_resource_group.res-group.location
    resource_group_name = azurerm_resource_group.res-group.name
    offer_type          = "Standard"
    kind                = "MongoDB"

    enable_automatic_failover = true

    consistency_policy {
        consistency_level       = "BoundedStaleness"
        max_interval_in_seconds = 10
        max_staleness_prefix    = 200
    }

    geo_location {
        prefix            = "${var.identifier}-cosmos-db-customid"
        location          = azurerm_resource_group.res-group.location
        failover_priority = 0
    }
}

resource "azurerm_cosmosdb_table" "cosmosdb-table" {
    name                = "${var.identifier}-cosmos-table"
    resource_group_name = azurerm_cosmosdb_account.cosmosdb.resource_group_name
    account_name        = azurerm_cosmosdb_account.cosmosdb.name
    throughput          = 400
}