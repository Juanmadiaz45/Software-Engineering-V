# Ansible Playbooks for Docker Installation and Running a Mario Bros Container

## Introduction
This project uses Ansible to automate the installation of Docker and the deployment of a Mario Bros game container on a remote virtual machine (VM). The project consists of two main playbooks:

- **install_docker.yml**: Installs Docker on the target VM.
- **run_container.yml**: Deploys a Docker container running the Mario Bros game.

The project is designed to be simple and reusable, leveraging Ansible's idempotent nature to ensure consistent results across multiple executions.

## Ansible Overview
Ansible is an open-source automation tool used for configuration management, application deployment, and task automation. It uses YAML-based playbooks to define tasks and roles, making it easy to read and write. Key features of Ansible include:

- **Agentless**: No need to install additional software on target machines.
- **Idempotent**: Ensures that running a playbook multiple times produces the same result.
- **Modular**: Uses roles and tasks to organize and reuse code.

## Project Structure
The project is organized as follows:

```plaintext
training-ansible/
├── inventory/
│   └── hosts.ini             # Inventory file defining the target VM
├── playbooks/
│   ├── install_docker.yml    # Playbook to install Docker
│   └── run_container.yml     # Playbook to run the Mario Bros container
├── roles/
│   ├── docker_install/
│   │   └── tasks/
│   │       └── main.yml      # Tasks to install Docker
│   └── docker_container/
│       └── tasks/
│           └── main.yml      # Tasks to run the Mario Bros container
└── ansible.cfg               # Ansible configuration file
```

## Inventory File (inventory/hosts.ini)
The inventory file defines the target VM where the playbooks will be executed. It includes the IP address, username, and password for SSH access.

```ini
[azure_vm]
vm-ip ansible_user=vmadmin ansible_ssh_pass=pass
```

- `vm-ip`: Replace this with the actual IP address of your VM.
- `ansible_user`: The username for SSH access.
- `ansible_ssh_pass`: The password for SSH access.

## Playbooks
### 1. install_docker.yml
This playbook installs Docker on the target VM. It uses the `docker_install` role to perform the following tasks:

- Install Docker dependencies.
- Add Docker's official GPG key.
- Add Docker's repository.
- Install Docker CE.

```yaml
---
- hosts: azure_vm
  become: yes
  roles:
    - docker_install
```

### 2. run_container.yml
This playbook deploys a Docker container running the Mario Bros game. It uses the `docker_container` role to perform the following tasks:

- Pull the `pengbai/docker-supermario` image.
- Run the container, mapping port 8787 on the host to port 8080 on the container.

```yaml
---
- hosts: azure_vm
  become: yes
  roles:
    - docker_container
```

## Roles
### 1. docker_install Role
This role installs Docker on the target VM. The tasks are defined in `roles/docker_install/tasks/main.yml`:

```yaml
- name: Install Docker dependencies
  apt:
    name:
      - apt-transport-https
      - ca-certificates
      - curl
      - software-properties-common
    state: present
    update_cache: yes

- name: Add Docker's official GPG key
  ansible.builtin.apt_key:
    url: https://download.docker.com/linux/ubuntu/gpg
    state: present

- name: Add Docker's repository
  ansible.builtin.apt_repository:
    repo: deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable
    state: present

- name: Install Docker CE
  apt:
    name: docker-ce
    state: present
    update_cache: yes
```

### 2. docker_container Role
This role runs the Mario Bros container. The tasks are defined in `roles/docker_container/tasks/main.yml`:

```yaml
- name: Run Mario Bros container
  docker_container:
    name: supermario-container
    image: "pengbai/docker-supermario:latest"
    state: started
    ports:
      - "8787:8080"
```

## Ansible Configuration (ansible.cfg)
The `ansible.cfg` file configures Ansible to:

- Disable host key checking.
- Specify the roles path.
- Define the inventory file.

```ini
[defaults]
host_key_checking = False
roles_path = ./roles
inventory = ./inventory/hosts.ini
```

## Commands to Execute the Playbooks
To execute the playbooks, use the following commands:

### Install Docker:
```bash
ansible-playbook -i inventory/hosts.ini playbooks/install_docker.yml
```

### Run the Mario Bros Container:
```bash
ansible-playbook -i inventory/hosts.ini playbooks/run_container.yml
```

## Security Rule for the VM
To access the Mario Bros game, you must allow inbound traffic on port 8787 in the VM's network security group (NSG). Add the following rule to your NSG configuration:

```hcl
security_rule {
    name                       = "mario_bros_rule"
    priority                   = 110  # Ensure the priority is unique
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8787"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
}
```

This rule allows traffic from any source IP to the VM on port 8787.

## Accessing the Mario Bros Game
Once the container is running and the security rule is in place, you can access the Mario Bros game by navigating to:

```
http://<VM_IP>:8787
```

Replace `<VM_IP>` with the public IP address of your VM.

## Evidence