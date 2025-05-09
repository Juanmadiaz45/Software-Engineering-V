provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "myfirtsvmrg" {
  name     = var.resource_group_name
  location = var.location
}

module "networking" {
  source = "./modules/networking"

  location            = azurerm_resource_group.myfirtsvmrg.location
  resource_group_name = azurerm_resource_group.myfirtsvmrg.name
  vnet_name           = var.vnet_name
  vnet_address_space  = var.vnet_address_space
  subnet_name         = var.subnet_name
  subnet_address_prefix = var.subnet_address_prefix
}

module "vm" {
  source = "./modules/vm"

  location            = azurerm_resource_group.myfirtsvmrg.location
  resource_group_name = azurerm_resource_group.myfirtsvmrg.name
  subnet_id           = module.networking.subnet_id
  vm_name             = var.vm_name
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
}