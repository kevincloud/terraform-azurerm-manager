from azure.cosmosdb.table.tableservice import TableService
from azure.cosmosdb.table.models import Entity

connection_string = "DefaultEndpointsProtocol=https;AccountName=kevincx-cosmos-db;AccountKey=u2y45eppqI8OjJbVGZxlyYBzFBVWrRdDnRNrWPLJh82F3z85Jy2RWG0nR96UUDBPVcIznqeggsUokOdqYdxquA==;TableEndpoint=https://kevincx-cosmos-db.table.cosmos.azure.com:443/;"
table_service = TableService(endpoint_suffix="table.cosmos.azure.com", connection_string=connection_string)

item = Entity()
item.PartitionKey = "required-modules"
item.RowKey = "custom-vnet"
table_service.insert_entity('kevincx-cosmos-table', item)

item = Entity()
item.PartitionKey = "required-modules"
item.RowKey = "custom-sg"
table_service.insert_entity('kevincx-cosmos-table', item)

item = Entity()
item.PartitionKey = "required-modules"
item.RowKey = "custom-blob"
table_service.insert_entity('kevincx-cosmos-table', item)

item = Entity()
item.PartitionKey = "approved-instances"
item.RowKey = "Standard_A1_v2"
table_service.insert_entity('kevincx-cosmos-table', item)

item = Entity()
item.PartitionKey = "approved-instances"
item.RowKey = "Standard_A2_v2"
table_service.insert_entity('kevincx-cosmos-table', item)

item = Entity()
item.PartitionKey = "approved-instances"
item.RowKey = "Standard_A4_v2"
table_service.insert_entity('kevincx-cosmos-table', item)

item = Entity()
item.PartitionKey = "approved-instances"
item.RowKey = "Standard_A8_v2"
table_service.insert_entity('kevincx-cosmos-table', item)

item = Entity()
item.PartitionKey = "prohibited-resources"
item.RowKey = "azurerm_resource_group"
table_service.insert_entity('kevincx-cosmos-table', item)

item = Entity()
item.PartitionKey = "prohibited-resources"
item.RowKey = "azurerm_virtual_network"
table_service.insert_entity('kevincx-cosmos-table', item)

item = Entity()
item.PartitionKey = "prohibited-resources"
item.RowKey = "azurerm_network_security_group"
table_service.insert_entity('kevincx-cosmos-table', item)

item = Entity()
item.PartitionKey = "prohibited-resources"
item.RowKey = "azurerm_subnet_network_security_group_association"
table_service.insert_entity('kevincx-cosmos-table', item)
