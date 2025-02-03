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
  - [Securing the database](#securing-the-database)
    - [Risks of our current setup](#risks-of-our-current-setup)
    - [Amendments to mitigate risks](#amendments-to-mitigate-risks)
    - [3-subnet architecture in Azure](#3-subnet-architecture-in-azure)
    - [Steps towards target architecture](#steps-towards-target-architecture)

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

## Securing the database

- Currently database is in private subnet and app is in public subnet. But no protections employed in the private subnet.
- For most applications, employing an architecture to protect the database is priority as the database often carries sensitive customer data e.g. transaction records.

### Risks of our current setup

1. Default Azure VNet communication, not as secure as everything can talk to everything.
2. Public IP for db vm, which we need currently to SSH into it. But allows other attackers to also be able to do the same.

### Amendments to mitigate risks

1. Allow port for mongodb traffic in DB VM NSG rules, deny everything else i.e. make it more like AWS. In other words, override default azure vnet behaviour of allowing all communication between resources in the same vnet.
2. Remove db vm public IP. SSH into app vm, and use as a jumpbox to ssh into db vm.
3. Setup DMZ subnet. Create vm in this subnet, NSG rule allow SSH so we can do our initial setup. This vm is called a Network Virtual Appliance (NVA) and is used to filter traffic heading towards db. Initially provide public IP for it, can remove later.
   1. Setup VNet route table: `to-private-subnet-route-table`. Add user-defined route to force traffic leaving public subnet to reach the NVA (next hop) in DMZ subnet.
   2. To allow the NVA to forward **any** network traffic to the db vm, need to enable `IP forwarding` both on the NIC via Azure platform but also the NVA vm itself via bash shell.
   3. Setup iptables rules on NVA vm to **only forward legitimate traffic**.
4. Set up stricter NSG rules on db vm.

### 3-subnet architecture in Azure

- Azure specific architecture, different in AWS.
- Target architecture for our setup as below.
  
![3-Subnet Architecture](<../images/3-Subnet Architecture.jpg>)

### Steps towards target architecture

1. Setup VNet and subnets.
   - Name: tech501-sameem-3-subnet-vnet
   - Address space: 10.0.0.0/16
   - Subnets:
     - Public subnet: 10.0.2.0/24
     - DMZ subnet: 10.0.3.0/24
     - Private subnet: 10.0.4.0
       - enable private (no default outbound access)
  
2. Create db vm.
   - Name: tech501-sameem-in-3-subnet-sparta-app-db
   - VNet/Subnet: tech501-sameem-3-subnet-vnet/private-subnet
   - Public IP: none
   - NSG: allow SSH (for now, will restrict these later)
   - Disk: standard SSD

3. Create app vm.
   - Name: tech501-sameem-in-3-subnet-sparta-app
   - VNet/Subnet: tech501-sameem-3-subnet-vnet/public-subnet
   - Public IP: new
   - NSG: allow SSH and HTTP
   - Disk: standard SSD
   - Advanced:
     - Enable User Data:
  
        ```bash
        #!/bin/bash
        cd tech501-sparta-app/app

        export DB_HOST=mongodb://<db_private_ip>:27017/posts

        pm2 start app.js
        ```

4. Confirm app and db posts load up.

5. Create the NVA vm
    - Name: tech501-sameem-in-3-subnet-sparta-app-nva
    - Image: Ubuntu 22.04 LTS
    - VNet/Subnet: tech501-sameem-3-subnet-vnet/DMZ-subnet
    - Public IP: new
    - NSG: allow SSH
    - Disk: standard SSD
  
6. Create the Route Table
    - Name: tech501-sameem-to-private-subnet-rt
    - Propagate gateway routes: yes
    - Add route (to route traffic to NVA)
      - name: to-private-subnet-route
      - destination IP addresses: 10.0.4.0/24
      - next hop type: virtual appliance
      - next hop IP address: 10.0.3.4
    - Add association (to associate the public subnet where the traffic is coming out of i.e. the source, to the added route above)
      - name: public-subnet
      - subnet address range: 10.0.2.0/24

    The configuration above forces traffic to route through the NVA, rather than direct to the db vm. See app terminal to verify pings are not being received by db once traffic is re-routed.

7. Enable IP forwarding on NVA
  
    - Currently NVA is not doing anything with the traffic it is receiving.
    - Need to enable IP forwarding on both the NIC (Azure) and the VM itself (Linux) so it forwards the traffic to the db. This is not enabled by default.

    Enable forwarding on NIC:

    - Network interface
      - Settings
        - IP Configurations
          - Enable IP forwarding (allow NVA to act as a router to forward traffic to db vm)

    Enable forwarding on the VM (linux):

    - `sysctl net.ipv4.ip_forward`: check forwarding status, 0 means not on.
    - `sudo nano /etc/sysctl.conf`, edit config and unhash line to enable ipv4 forwarding.
    - `sudo sysctl -p`, reload config file, should show forwarding status as 1 now.

    - Re-check app vm terminal, ping to the db vm should have resumed.
    - So now traffic from app vm is routing through the nva to reach the db.
  
8. Set IP tables rules (firewalls rules)

    - Without these rules, all traffic from app vm entering the nva vm, will be forwarded to the db vm. We need these rules to filter the traffic we forward to the db.
  
    - Ensure iptables is installed:

    ```bash
    sudo iptables --help
    ```

    - Run a bash script to install all the IP table rules we need. Can call it `config-ip-tables.sh`. Contents as below:

    ```bash
    #!/bin/bash
    
    # configure iptables
    
    echo "Configuring iptables..."
    
    # Allow all loopback (lo) traffic
    sudo iptables -A INPUT -i lo -j ACCEPT
    sudo iptables -A OUTPUT -o lo -j ACCEPT
    
    # Allow established and related incoming connections
    sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    
    # Allow established outgoing connections
    sudo iptables -A OUTPUT -m state --state ESTABLISHED -j ACCEPT
    
    # Drop invalid packets
    sudo iptables -A INPUT -m state --state INVALID -j DROP
    
    # Allow incoming SSH connections on port 22
    sudo iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
    sudo iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
    
    # uncomment the following lines if want allow SSH into NVA only through the public subnet (app VM as a jumpbox)
    # this must be done once the NVA's public IP address is removed
    #sudo iptables -A INPUT -p tcp -s 10.0.2.0/24 --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
    #sudo iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
    
    # uncomment the following lines if want allow SSH to other servers using the NVA as a jumpbox
    # if need to make outgoing SSH connections with other servers from NVA
    #sudo iptables -A OUTPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    #sudo iptables -A INPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT
    
    # Allow forwarding of MongoDB traffic from the public subnet (10.0.2.0/24) to the private subnet (10.0.4.0/24) on port 27017
    sudo iptables -A FORWARD -p tcp -s 10.0.2.0/24 -d 10.0.4.0/24 --destination-port 27017 -m tcp -j ACCEPT
    
    # Allow forwarding of ICMP (ping) traffic from the public subnet (10.0.2.0/24) to the private subnet (10.0.4.0/24)
    sudo iptables -A FORWARD -p icmp -s 10.0.2.0/24 -d 10.0.4.0/24 -m state --state NEW,ESTABLISHED -j ACCEPT
    
    # Set default policy to drop all incoming traffic
    sudo iptables -P INPUT DROP
    
    # Set default policy to drop all forwarding traffic
    sudo iptables -P FORWARD DROP
    
    echo "Done!"
    echo ""
    
    # make iptables rules persistent
    # it will ask for user input by default
    
    echo "Make iptables rules persistent..."
    sudo DEBIAN_FRONTEND=noninteractive apt install iptables-persistent -y
    echo "Done!"
    echo ""
    ```

    - **Script details**:

      - Loopback Traffic: Allows all traffic on the loopback interface (lo), which is used for internal communication within the host (NVA).
      - Established Connections: Allows incoming (from app) and outgoing (to db) traffic for established and related connections.
      - Invalid Packets: Drops any invalid packets.
      - SSH Traffic: Allows incoming and outgoing SSH traffic on port 22.
      - Forwarding Rules:
        - MongoDB Traffic: Allows forwarding of MongoDB traffic from the public subnet to the private subnet on port 27017.
        - ICMP Traffic: Allows forwarding of ICMP (ping) traffic from the public subnet to the private subnet.
      - Default Policies: Sets the default policy to drop all incoming and forwarding traffic.
      - Persisting Rules: Installs iptables-persistent to save the iptables rules so they persist across reboots.

    - use chmod to give execute permissions to the script and then run:

    ```bash
    chmod +x config-ip-tables.sh
    ./config-ip-tables.sh
    ```

    - So by this point, the app and the db posts page should continue to load and the pings from the app vm to the db vm should also continue to send as allowed by the ICMP iptables rule in the script.
  
9. Add further db vm nsg rules

   - We can add two further nsg rules for the db vm:
     - Allow mongodb traffic
     - Deny all other traffic

   - Test that this is successful will be that our pings from app vm to db vm stop working (as pings use ICMP which as you can see below we have not explicitly allowed so will be blocked under our "denyall" rule).

   - Nonetheless, our app and posts page should continue to load.

   - tech501-sameem-in-3-subnet-sparta-app-db-nsg
     - settings
       - inbound security rules
         - Add
           - Source: IP Addresses
           - Source IP Addresses: 10.0.2.0
           - Source port ranges: *
           - Destination: Any
           - Service: MongoDB
           - Action: Allow
           - Priority: 310
           - Name: AllowCidrBlockMongoDBInbound
         - Add
           - Source: Any
           - Source port ranges: *
           - Destination: Any
           - Service: Custom
           - Destination port ranges: *
           - Protocol: Any
           - Action: Deny
           - Priority: 1000
           - Name: DenyAnyCustomAnyInbound
           - Description: Deny everything else rule.
  