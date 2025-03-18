# Automated Azure VM Deployment Using Terraform

## Introduction
This document describes how to create a virtual machine (VM) in Microsoft Azure using Terraform.

## Project Structure
The project consists of the following files:

- main.tf: Defines the Azure resources to be created.

- variables.tf: Contains the variables used in the configuration.

- terraform.tfvars: Provides specific values for the variables.

## Terraform Configuration
### main.tf
This file contains the definition of the Azure resources to be created. Below is a description of each section:

Provider: Configures the Azure provider (azurerm).
```
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
```

Resource Group: Creates a resource group in Azure.
```
resource "azurerm_resource_group" "myfirtsvmrg" {
  name     = var.resource_group_name
  location = var.location
}
```


Virtual Network: Defines a virtual network within the resource group.
```
resource "azurerm_virtual_network" "myfirtsvmvnet" {
  name                = "myfirtsvmvnet"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.myfirtsvmrg.location
  resource_group_name = azurerm_resource_group.myfirtsvmrg.name
}
```

Subnet: Creates a subnet within the virtual network.
```
resource "azurerm_subnet" "myfirtsvmsubnet" {
  name                 = "myfirtsvmsubnet"
  resource_group_name  = azurerm_resource_group.myfirtsvmrg.name
  virtual_network_name = azurerm_virtual_network.myfirtsvmvnet.name
  address_prefixes     = var.subnet_address_prefix
}
```

Public IP: Assigns a public IP address to the VM.
```
resource "azurerm_public_ip" "myfirtsvmpublicip" {
  name                = "myfirtsvmpublicip"
  location            = azurerm_resource_group.myfirtsvmrg.location
  resource_group_name = azurerm_resource_group.myfirtsvmrg.name
  allocation_method   = "Static"
}
```

Network Interface: Creates a network interface for the VM.
```
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
```

Network Security Group: Defines a network security group to control inbound and outbound traffic.
```
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
```

Network Interface Security Group Association: Associates the network security group with the network interface.
```
resource "azurerm_network_interface_security_group_association" "myfirtsvmnicnsg" {
  network_interface_id      = azurerm_network_interface.myfirtsvmnic.id
  network_security_group_id = azurerm_network_security_group.myfirtsvmsg.id
}
```

Virtual Machine: Creates the virtual machine.
```
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
```

### variables.tf
This file defines the variables used in the Terraform configuration.
```
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "myfirtsvmrg"
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
  default     = "Standard_F2"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "adminuser"
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
  default     = "my-firts-vm"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefix" {
  description = "Address prefix for the subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}
```

### terraform.tfvars
This file provides specific values for the variables defined in variables.tf.

```
subscription_id = "c7a952cf-eff5-49e9-bed2-4d028efede40"
location        = "West Europe"
admin_username  = "adminuser"
admin_password  = "Password@123"
```

## Deployment
### Initialization
Run the following command to initialize the Terraform working directory:
```
terraform init
```

### Validation
Validate the configuration with the following command:
```
terraform validate
```

### Planning
Generate an execution plan to review the changes Terraform will apply:
```
terraform plan
```

### Application
Apply the configuration to create the resources in Azure:
```
terraform apply
```
Terraform will display a summary of the resources to be created. Confirm the action by typing yes.

### Cleanup
To remove all created resources, run:
```
terraform destroy
```
This will delete all resources defined in the Terraform configuration.

## Evidence