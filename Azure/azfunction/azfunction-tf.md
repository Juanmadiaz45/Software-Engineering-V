# Automated Azure Function App Deployment Using Terraform
## Introduction
This document describes how to create an Azure Function App along with its associated resources (Storage Account, Service Plan, and a sample function) using Terraform.

## Project Structure
The project consists of the following files:

- main.tf: Defines the Azure resources to be created.

- variables.tf: Contains the variables used in the configuration.

- terraform.tfvars: Provides specific values for the variables.

- outputs.tf: Defines the outputs after deployment.

## Terraform Configuration
### main.tf
This file contains the definition of the Azure resources to be created. Below is a description of each section:

Provider: Configures the Azure provider (azurerm).
```hcl
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
```

Resource Group: Creates a resource group in Azure.
```hcl
resource "azurerm_resource_group" "rg" {
  name     = var.name_function
  location = var.location
}
```

Storage Account: Creates a Storage Account for the Function App.
```hcl
resource "azurerm_storage_account" "sa" {
  name                     = var.name_function
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

Service Plan: Defines the Service Plan for the Function App.
```hcl
resource "azurerm_service_plan" "sp" {
  name                = var.name_function
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Windows"
  sku_name            = "Y1"
}
```

Function App: Creates the Azure Function App.
```hcl
resource "azurerm_windows_function_app" "wfa" {
  name                = var.name_function
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  service_plan_id            = azurerm_service_plan.sp.id

  site_config {
    application_stack {
      node_version = "~18"
    }
  }
}
```

Sample Function: Creates a sample function within the Function App.
```hcl
resource "azurerm_function_app_function" "faf" {
  name            = var.name_function
  function_app_id = azurerm_windows_function_app.wfa.id
  language        = "Javascript"

  # Load sample code into the function
  file {
    name    = "index.js"
    content = file("example/index.js")
  }

  # Define test payload
  test_data = jsonencode({
    "name" = "Azure"
  })

  # Map HTTP requests
  config_json = jsonencode({
    "bindings" : [
      {
        "authLevel" : "anonymous",
        "type" : "httpTrigger",
        "direction" : "in",
        "name" : "req",
        "methods" : [
          "get",
          "post"
        ]
      },
      {
        "type" : "http",
        "direction" : "out",
        "name" : "res"
      }
    ]
  })
}
```

### variables.tf
This file defines the variables used in the Terraform configuration.

```hcl
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "name_function" {
  description = "Name of the Function App and associated resources"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "West Europe"
}
```

### terraform.tfvars
This file provides specific values for the variables defined in variables.tf.

```hcl
subscription_id = "id"
name_function   = "my-function-app"
location        = "West Europe"
```

### outputs.tf
This file defines the outputs after deployment.

```hcl
output "function_app_url" {
  value       = azurerm_windows_function_app.wfa.default_hostname
  description = "URL of the Function App"
}

output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "Name of the resource group"
}

output "storage_account_name" {
  value       = azurerm_storage_account.sa.name
  description = "Name of the Storage Account"
}

output "function_app_function_url" {
  value       = azurerm_function_app_function.faf.invocation_url
  description = "URL of the sample function within the Function App"
}
```

## Deployment
### Initialization
Run the following command to initialize the Terraform working directory:

```bash
terraform init
```

### Validation
Validate the configuration with the following command:

```bash
terraform validate
```

### Planning
Generate an execution plan to review the changes Terraform will apply:

```bash
terraform plan
```

### Application
Apply the configuration to create the resources in Azure:

```bash
terraform apply
```
Terraform will display a summary of the resources to be created. Confirm the action by typing yes.

Cleanup
To remove all created resources, run:

```bash
terraform destroy
```

This will delete all resources defined in the Terraform configuration.

## Evidence

![alt text](image.png)

![alt text](image-1.png)