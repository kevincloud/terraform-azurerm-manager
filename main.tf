provider "aws" {
    region = var.aws_region
}

provider "azurerm" {
    version = "~> 2.13.0"
    features {}
}
