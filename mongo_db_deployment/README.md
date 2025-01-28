# MongoDB deployment

- [MongoDB deployment](#mongodb-deployment)
  - [Preparation](#preparation)
    - [Create database VM](#create-database-vm)
    - [SSH into the VM](#ssh-into-the-vm)
    - [Update and Upgrade Ubuntu packages](#update-and-upgrade-ubuntu-packages)
  - [Installing MongoDB](#installing-mongodb)
    - [Install gnupg and curl\*\*](#install-gnupg-and-curl)
    - [Import the MongoDB public GPG key\*\*](#import-the-mongodb-public-gpg-key)
    - [Create the list file](#create-the-list-file)
    - [Reload package database](#reload-package-database)
    - [Install mongo db components\*\*](#install-mongo-db-components)
    - [OPTIONAL protect installed versions](#optional-protect-installed-versions)
    - [Enable mongodb service](#enable-mongodb-service)
    - [Start mongodb service](#start-mongodb-service)
  - [Check the mongodb status](#check-the-mongodb-status)
    - [Change the bindIp in the mongod.conf file](#change-the-bindip-in-the-mongodconf-file)
    - [Restart the mongodb service](#restart-the-mongodb-service)
  - [Creating a generalised Azure image from mongodb VM](#creating-a-generalised-azure-image-from-mongodb-vm)
    - [Document your Commands for Dependencies](#document-your-commands-for-dependencies)
    - [Run waagent command](#run-waagent-command)
    - [Stop the VM on the azure portal](#stop-the-vm-on-the-azure-portal)
    - [Capture the image](#capture-the-image)
    - [Deploy a VM from the image](#deploy-a-vm-from-the-image)

## Preparation

### Create database VM

- name: `tech501-sameem-sparta-app-db-vm`
- resource_group: `tech501`
- image: `Ubuntu 22.04 LTS`
- NSG: `allow SSH`
- Size: `B1s`
- Public IP: `yes`
- VNet/Subnet: `tech501-sameem-2-subnet-vnet/private-subnet`
- tag: `owner:Sameem`

- Unlike AWS, by default Azure allows resources deployed in the same vnet to talk to each other. So don't need to allow mongodb database port access for the app to connect to it.

### SSH into the VM

```bash
ssh -i <private_key_path> <username>@<db_vm_public_ip>
```

### Update and Upgrade Ubuntu packages

```bash
sudo apt update && sudo apt upgrade -y
```

## Installing MongoDB

### Install gnupg and curl**

```bash
sudo apt install gnupg curl -y
```

### Import the MongoDB public GPG key**

```bash
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor
```

### Create the list file

- Create the list file /etc/apt/sources.list.d/mongodb-org-7.0.list for your version of Ubuntu.

```bash
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
```

### Reload package database

```bash
sudo apt update
```

### Install mongo db components**

- Install version 7.0.6

```bash
sudo apt-get install -y mongodb-org=7.0.6 mongodb-org-database=7.0.6 mongodb-org-server=7.0.6 mongodb-mongosh mongodb-org-mongos=7.0.6 mongodb-org-tools=7.0.6
```

### OPTIONAL protect installed versions

- Can use these commands to ensure that this version doesn't get upgraded with other components when running `sudo apt upgrade`.

```bash
echo "mongodb-org hold" | sudo dpkg --set-selections echo "mongodb-org-database hold" | sudo dpkg --set-selections echo "mongodb-org-server hold" | sudo dpkg --set-selections echo "mongodb-mongosh hold" | sudo dpkg --set-selections echo "mongodb-org-mongos hold" | sudo dpkg --set-selections echo "mongodb-org-tools hold" | sudo dpkg --set-selections
```

### Enable mongodb service

- Enable to auto start the mongodb service whenever the VM is started.

```bash
sudo systemctl enable mongod
```

### Start mongodb service

```bash
sudo systemctl start mongod
```

## Check the mongodb status

```bash
sudo systemctl status mongod
```

### Change the bindIp in the mongod.conf file

- Change bindIP to 0.0.0.0 to allow the db to be accessed from other VMs, not just the VM it sits in. Allows our app to access the db as a result.

```bash
sudo nano /etc/mongod.conf
```

### Restart the mongodb service

- After making changes e.g. bindIp, need to restart the service to apply.

```bash
sudo systemctl restart mongod
```

## Creating a generalised Azure image from mongodb VM

- Similar to how we created this for the app vm, we want to do this so that we can deploy any number of mongodb vm instances with all the dependencies as above.

### Document your Commands for Dependencies

- This can include updating packages, installing nginx, nodejs and npm, and other dependencies.
- These may be needed for troubleshooting or reinstallation later so needs to be kept safe.

### Run waagent command

- Deletes adminuser home directory.
  
```bash
sudo waagent -deprovision+user
```

### Stop the VM on the azure portal

### Capture the image

### Deploy a VM from the image

- Check if the vm has mongodb installed already.

```bash
sudo systemctl status mongod
```

- Should see db running as we had enabled it in the vm we used to create the image.
