# Azure Autoscaling

- [Azure Autoscaling](#azure-autoscaling)
  - [Types of scaling](#types-of-scaling)
  - [Benefits of Autoscaling](#benefits-of-autoscaling)
  - [Autoscaling in Azure](#autoscaling-in-azure)
    - [Virtual Machine Scale Sets (VMSS)](#virtual-machine-scale-sets-vmss)
    - [VMSS Key Features](#vmss-key-features)
    - [VMSS Prerequisites](#vmss-prerequisites)
    - [Creation Fields](#creation-fields)
    - [Reimaging](#reimaging)
      - [Key Points](#key-points)
    - [Health Check](#health-check)

## Types of scaling

- Two types: Vertical and horizontal.
- Vertical = increase physical resources of the instance e.g. more CPU or ram.
- Horizontal = increase number of instances. Can predefine conditions such as if CPU >= 80%, add another instance.
- **Autoscaling** in azure typically refers to horizontal scaling.
- Scale out instances can be different sizes in Azure.

## Benefits of Autoscaling

- Worse to better:

    **No monitoring** -> **Dashboards** -> **Alerts** -> **Autoscaling**.

- Autoscaling is used to prevent downtime of our application and improve user experience as traffic is load balanced between our app instances.

## Autoscaling in Azure

### Virtual Machine Scale Sets (VMSS)

- Azure Virtual Machine Scale Sets (VMSS) are a service that allows you to deploy and manage a set of identical, auto-scaling virtual machines.
- VMSS is designed to support large-scale services and applications, providing high availability and scalability.

### VMSS Key Features

- **Auto-Scaling**: Automatically increases or decreases the number of VMs based on demand or a defined schedule.
- **Load Balancing**: Distributes incoming traffic across multiple VMs to ensure even load distribution and high availability.
- **High Availability**: Ensures that your application remains available even if some VMs fail.
- **Integration**: Works seamlessly with other Azure services like Azure Load Balancer, Azure Application Gateway, and Azure Monitor.
- **Custom Images**: Allows you to use custom VM images or Azure Marketplace images for your scale sets.
- **Configuration Management**: Supports configuration management tools like Azure Automation, Chef, and Puppet.

- VMSS is ideal for applications that require high availability, scalability, and the ability to handle large volumes of traffic.

### VMSS Prerequisites

- Generalised image, what we created previously. Will be used by VMSS.

### Creation Fields

- Basics:
  - Resource Group: tech501
  - Name: tech501-sameem-sparta-app-vmss-2
  - Availability zones: 1, 2, 3
  - Orchestration mode: Uniform
  - Security Type: Standard
  - Scaling Mode: Autoscaling
  - Scaling configuration: Choose configure
    - Default Instance Count: 2
    - Minimum: 2
    - Maximum: 3
    - CPU threshold: 75%
    - Increase instance count by: 1
  - Image: tech501-sameem-deploy-app-generalised-vm-image-20250128180630
  - Size: Standard B1s
  - SSH public key:
    - Username: adminuser
    - Stored Keys: tech501-sameem-az-key
    - Licensing type: Other

- Disks:
  - OS disk type: Standard SSD

- Networking
  - VNet Configuration
    - VNet: tech501-sameem-2-subnet-vnet
    - Subnet: public-subnet

  - Network Interface
    - Name: tech501-sameem-2-subnet-vnet-nic01
    - Subnet: public-subnet
    - NIC NSG: Advanced
      - tech501-sameem-sparta-app-vmss-2-nsg
      - public IP address: disabled

  - Load Balancing
    - Azure Load Balancer
    - Select Load balancer: Create a load balancer
      - Name: tech501-sameem-sparta-app-lb-2
      - Type: public
      - Protocol: TCP
      - Rules:
        - Load Balancer Rule (controls traffic forwarding between lb and vms)
          - Frontend port: 80
          - Backend port: 80 (if reverse proxy set up keep as 80)
        - Inbound NAT rule (controls how you reach the vms behind the lb)
          - Frontend port range start: 50000 (ssh to port 50000 to reach first vm, incrementing by one for the next etc)
          - Backend port: 22

- Health
  - Health
    - Enable application health monitoring
  - Recovery (recovers instance if unhealthy for grace period duration)
    - Automatic repairs
    - Repair actions: replace
    - Grace period (min): 10

- Advance
  - User data:
  
```bash
#!/bin/bash
cd tech501-sparta-app/app
pm2 start app.js
```

- Tags
  - Owner: Sameem

![VMSS/LB Architecture](<../images/vmss_lb architecture.jpg>)

### Reimaging

- The **Reimage** option in the Virtual Machine Scale Sets (VMSS) instances tab allows you to reset one or more virtual machine instances to their original state using the base image specified in the scale set configuration.
- This process effectively reinstalls the operating system and any pre-configured software, returning the VM to its initial state.

#### Key Points

- **Purpose**: Used to repair or refresh a VM instance that may be experiencing issues or to ensure consistency across instances.
- **Data Loss**: Any data stored on the VM's temporary disk will be lost. Data on attached persistent disks will remain intact.
- **Usage**: Typically used for maintenance, troubleshooting, or to revert changes that may have caused instability.

- Reimaging is a useful feature for maintaining the health and consistency of your VM instances within a scale set.

- In our case, because we have used **User Data** which is not persistent between VM restarts, need to **Reimage** after any VM restarts for the app to run as expected.

### Health Check

- If port 80 on the load balancer is reachable, returns a HTTP 200 success.
- "Health state" field only shows if the VM is running.
