resource "azurerm_public_ip" "myfirtsvmpublicip" {
  name                = "myfirtsvmpublicip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "myfirtsvmnic" {
  name                = "myfirtsvmnic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myfirtsvmpublicip.id
  }
}

resource "azurerm_network_security_group" "myfirtsvmsg" {
  name                = "myfirtsvmsg"
  location            = var.location
  resource_group_name = var.resource_group_name

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
  security_rule {
    name                       = "mario_bros_rule"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8787"
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
  resource_group_name = var.resource_group_name
  location            = var.location
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