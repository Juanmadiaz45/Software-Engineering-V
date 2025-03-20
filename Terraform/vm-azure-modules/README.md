# Automated Azure VM Deployment Using Terraform with Modules

## Introduction
This project demonstrates how to create a virtual machine (VM) in Microsoft Azure using Terraform with a modular approach. The project is organized into reusable modules for networking and VM creation, making it easy to maintain, scale, and reuse in other projects.

## How It Works

### Provider Configuration:

- The main.tf file in the root directory configures the Azure provider and defines the required subscription ID.

### Resource Group:

- A resource group is created to logically group all resources (e.g., VNet, subnet, VM).

### Networking Module:

- The networking module creates:

  - A Virtual Network (VNet) with a specified address space.

  - A Subnet within the VNet.

  - The subnet ID is exported as an output and passed to the VM module.

### VM Module:

  - The vm module creates:

  - A Public IP address for the VM.

  - A Network Interface (NIC) connected to the subnet.

  - A Network Security Group (NSG) with an SSH rule to allow inbound traffic.

  - A Linux Virtual Machine with Ubuntu 22.04 LTS as the OS.

### Outputs:

- The public IP address of the VM is outputted, allowing you to connect to the VM via SSH.

## Project Structure
```
.
├── main.tf                  # Root configuration
├── variables.tf             # Root variables
├── terraform.tfvars         # Variable values
└── modules/
    ├── networking/          # Networking module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── vm/                  # VM module
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Deployment
### Initialization
Run the following command to initialize the Terraform working directory:
```hcl
terraform init
```

### Validation
Validate the configuration with the following command:
```hcl
terraform validate
```

### Planning
Generate an execution plan to review the changes Terraform will apply:
```hcl
terraform plan
```

### Application
Apply the configuration to create the resources in Azure:
```hcl
terraform apply
```
Terraform will display a summary of the resources to be created. Confirm the action by typing yes.

### Cleanup
To remove all created resources, run:
```hcl
terraform destroy
```
This will delete all resources defined in the Terraform configuration.

## Evidence

![image](https://github.com/user-attachments/assets/76d9b7f0-c5bd-488c-a8ce-1e02cf67ee0f)

![image](https://github.com/user-attachments/assets/9d408223-666e-4d6f-a961-0b961141232f)
