resource "azurerm_resource_group" "res-group" {
        name = "${var.identifier}-resources"
        location = var.azure_location

        tags = {
            environment = "Dev"
            Key = "DoNotDelete"
        }
}

resource "azurerm_virtual_network" "vnet" {
    name                = "${var.identifier}-network"
    address_space       = ["10.0.0.0/16"]
    location            = var.azure_location
    resource_group_name = azurerm_resource_group.res-group.name

    tags = {
        environment = "Dev"
        Key = "DoNotDelete"
    }
}

resource "azurerm_subnet" "public-subnet" {
    name                 = "${var.identifier}-subnet"
    resource_group_name  = azurerm_resource_group.res-group.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes      = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "network-sg" {
    name                = "${var.identifier}-sg"
    location            = var.azure_location
    resource_group_name = azurerm_resource_group.res-group.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "HTTP"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
        Key = "DoNotDelete"
    }
}

resource "azurerm_subnet_network_security_group_association" "nsg-assoc" {
    subnet_id                 = azurerm_subnet.public-subnet.id
    network_security_group_id = azurerm_network_security_group.network-sg.id
}

resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.res-group.name
    }

    byte_length = 8
}

resource "azurerm_storage_account" "blob-store" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.res-group.name
    location                    = var.azure_location
    account_replication_type    = "LRS"
    account_tier                = "Standard"

    tags = {
        environment = "Dev"
        Key = "DoNotDelete"
    }
}

resource "azurerm_public_ip" "public-ip" {
    name                         = "${var.identifier}-public-ip"
    location                     = var.azure_location
    resource_group_name          = azurerm_resource_group.res-group.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Dev"
        Key = "DoNotDelete"
    }
}

resource "azurerm_network_interface" "nic" {
    name                        = "${var.identifier}-nic"
    location                    = var.azure_location
    resource_group_name         = azurerm_resource_group.res-group.name

    ip_configuration {
        name                          = "kcNicConfiguration"
        subnet_id                     = azurerm_subnet.public-subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.public-ip.id
    }

    tags = {
        environment = "Dev"
        Key = "DoNotDelete"
    }
}

# resource "azurerm_virtual_machine" "azure-vm" {
#     name                  = "${var.identifier}-vm"
#     location              = var.azure_location
#     resource_group_name   = azurerm_resource_group.res-group.name
#     network_interface_ids = [azurerm_network_interface.nic.id]
#     vm_size               = "Standard_A1_v2"

#     storage_image_reference {
#         publisher = "Canonical"
#         offer     = "UbuntuServer"
#         sku       = "18.04-LTS"
#         version   = "latest"
#     }

#     storage_os_disk {
#         name              = "kcOsDisk"
#         caching           = "ReadWrite"
#         create_option     = "FromImage"
#         managed_disk_type = "Standard_LRS"
#     }

#     os_profile {
#         computer_name  = var.identifier
#         admin_username = var.linux_user
#         admin_password = var.linux_pass
#         custom_data = templatefile("${path.module}/scripts/install.sh", {
#             ARM_SUBSCRIPTION_ID = var.arm_sub_id
#             ARM_TENANT_ID = var.arm_tenant_id
#             ARM_CLIENT_ID = var.arm_client_id
#             ARM_CLIENT_SECRET = var.arm_secret_id
#             IDENTIFIER = var.identifier
#             ACCOUNT_KEY = var.account_key
#         })
#     }

#     os_profile_linux_config {
#         disable_password_authentication = false
#     }

#     boot_diagnostics {
#         enabled     = "true"
#         storage_uri = azurerm_storage_account.blob-store.primary_blob_endpoint
#     }

#     identity {
#         type = "SystemAssigned"
#     }

#     tags = {
#         environment = "Dev"
#         Key = "DoNotDelete"
#     }
# }

# data "azurerm_subscription" "current" {}

# data "azurerm_role_definition" "contributor" {
#     name = "Contributor"
# }

# resource "azurerm_role_assignment" "assignrole" {
#     name               = azurerm_virtual_machine.azure-vm.name
#     scope              = data.azurerm_subscription.current.id
#     role_definition_id = "${data.azurerm_subscription.current.id}${data.azurerm_role_definition.contributor.id}"
#     principal_id       = azurerm_virtual_machine.azure-vm.identity.0.principal_id
# }

# data "azurerm_public_ip" "public-ip" {
#     name                = azurerm_public_ip.public-ip.name
#     resource_group_name = azurerm_resource_group.res-group.name
#     depends_on = [azurerm_public_ip.public-ip]
# }
