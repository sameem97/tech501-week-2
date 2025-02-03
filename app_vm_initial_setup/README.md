# Intro to Automation

## Levels of Automation

![Levels of Automation](<../images/levels of automation.jpg>)

### Manual

- **Description**: Involves manually installing dependencies and configuring the environment by connecting to the VM via SSH.

- **Example**: Using SSH to connect to the VM and running commands like `sudo apt-get install -y nodejs` to install Node.js.

### Bash Script Automation

- **Description**: Automates the installation and configuration process by running a predefined bash script.

- **Example**: Creating a `setup.sh` script that includes all necessary commands and executing it on the VM.
  
```bash
#!/bin/bash
sudo apt-get update
sudo apt-get install -y nodejs mongodb
```

### User Data Field in Azure VM Deployment

- Description: Automates the initial setup by providing a script in the user data field during VM creation in the Azure portal.

- Example: Adding a bash script in the user data field to run during the VM's first boot.

```bash
sudo apt-get update
sudo apt-get install -y nodejs mongodb
```

### Generalised Image for Deployment

- Description: Creates a VM image with all necessary software pre-installed, which can be used to deploy new VMs quickly.

- Example: Creating a custom VM image with Node.js and MongoDB pre-installed and using it for new VM deployments.

### Full Automation with User Data and Image

- Description: Combines the use of a generalized image and user data scripts to fully automate the VM creation and setup process.

- Example: Deploying a VM using a custom image and providing additional configuration via the user data field.

## Automation employed for our setup

- [User data bash script](./run_app_only.sh)
- Generalised image created for both the db and the app.

- The user data script will run only once upon the VM creation, and will get the application running and connected to the database and reseed the database.
- So you should be able to access the app homepage and the db posts upon VM creation.
