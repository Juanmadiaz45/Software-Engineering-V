provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "myfirtsvmrg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "myfirtsvmvnet" {
  name                = "myfirtsvmvnet"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.myfirtsvmrg.location
  resource_group_name = azurerm_resource_group.myfirtsvmrg.name
}

resource "azurerm_subnet" "myfirtsvmsubnet" {
  name                 = "myfirtsvmsubnet"
  resource_group_name  = azurerm_resource_group.myfirtsvmrg.name
  virtual_network_name = azurerm_virtual_network.myfirtsvmvnet.name
  address_prefixes     = var.subnet_address_prefix
}

resource "azurerm_public_ip" "myfirtsvmpublicip" {
  name                = "myfirtsvmpublicip"
  location            = azurerm_resource_group.myfirtsvmrg.location
  resource_group_name = azurerm_resource_group.myfirtsvmrg.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "myfirtsvmnic" {
  name                = "myfirtsvmnic"
  location            = azurerm_resource_group.myfirtsvmrg.location
  resource_group_name = azurerm_resource_group.myfirtsvmrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.myfirtsvmsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myfirtsvmpublicip.id
  }
}

resource "azurerm_network_security_group" "myfirtsvmsg" {
  name                = "myfirtsvmsg"
  location            = azurerm_resource_group.myfirtsvmrg.location
  resource_group_name = azurerm_resource_group.myfirtsvmrg.name

  security_rule {
    name                       = "ssh_rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "myfirtsvmnicnsg" {
  network_interface_id      = azurerm_network_interface.myfirtsvmnic.id
  network_security_group_id = azurerm_network_security_group.myfirtsvmsg.id
}

resource "azurerm_linux_virtual_machine" "my-firts-vm" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.myfirtsvmrg.name
  location            = azurerm_resource_group.myfirtsvmrg.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.myfirtsvmnic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  disable_password_authentication = false
  provision_vm_agent              = true
}