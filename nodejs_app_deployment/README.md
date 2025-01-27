# Deploying Node.js app onto Azure VM

- [Deploying Node.js app onto Azure VM](#deploying-nodejs-app-onto-azure-vm)
  - [Manual](#manual)
    - [Create VM](#create-vm)
    - [SSH into VM](#ssh-into-vm)
    - [Run Commands](#run-commands)
    - [Get app code onto the VM](#get-app-code-onto-the-vm)
      - [1. SCP from local machine to the VM](#1-scp-from-local-machine-to-the-vm)
      - [2. Git Clone from GitHub repository](#2-git-clone-from-github-repository)
    - [Run the application](#run-the-application)
    - [Accessing the Application](#accessing-the-application)
  - [Create Azure image of VM for generalisation](#create-azure-image-of-vm-for-generalisation)
    - [1. Document your Commands for Dependencies](#1-document-your-commands-for-dependencies)
    - [2. Move App Code to the Root Directory](#2-move-app-code-to-the-root-directory)
    - [3. Run the waagent command](#3-run-the-waagent-command)
    - [4. Create the Azure Image](#4-create-the-azure-image)
    - [5. Test the image](#5-test-the-image)

## Manual

### Create VM

- Name: tech501-sameem-first-deploy-app-vm
- Image: Ubuntu Server 22.04 LTS - x64 gen2
- Use SSH authentication with your public key stored in azure
- Create advanced networking rule, to allow http (80), ssh (22) and node (3000): `tech501-sameem-sparta-app-allow-HTTP-SSH-3000`

### SSH into VM

- `ssh -i <private key path> <username>@<VM public IP>`
- `uname --all` tells you about the image you are running.

### Run Commands

- Once you've logged on to the VM, run these commands:

  - To check and update package lists: `sudo apt update && sudo apt upgrade -y`
  - To install nginx: `sudo apt install nginx -y`
  - To ensure nginx is running:`sudo systemctl status nginx` 
  - To install npm and node.js: `sudo DEBIAN_FRONTEND=noninteractive bash -c "curl -fsSL https://deb.nodesource.com/setup_20.x | bash -" && \ sudo DEBIAN_FRONTEND=noninteractive  apt-get install -y nodejs`
  - Check installations by running: `node -v` and `npm -v`.

### Get app code onto the VM

- Download code and extract onto your local machine.
- Follow one of the methods below.

#### 1. SCP from local machine to the VM

- Transfer to VM using SCP: `scp -i <private key path> -r <path to downloaded app> <username>@<VM public IP>:~`

#### 2. Git Clone from GitHub repository

- Create local git repository on your local machine and push to GitHub.
- SSH into the VM and run`git clone <repo url>` to get the app code from GitHub onto the VM.

### Run the application

- Within the VM terminal, `cd` into the `app` directory of the repository.
- Run `npm install` to install dependencies.
- Run `npm start` to start the application on port 3000.

### Accessing the Application

- To access the application, in the browser search bar enter: `<VM public IP>:3000`.
- You should see the application appear as below.

![nodejs test app](../images/nodejs_test_app.png)

## Create Azure image of VM for generalisation

- The steps below prepare the node.js test app for generalisation.
- The result is an azure image that can be used to deploy a number of VMs with the required source code and dependencies to run the application, skipping the previous manual steps.

### 1. Document your Commands for Dependencies

- This can include updating packages, installing nginx, nodejs and npm, and other dependencies.
- You can store this in a markdown file or in my case, a [bash script](/nodejs_app_deployment/deploy_nodejs_app.sh).
- These may be needed for troubleshooting or resinstallation later so needs to be kept safe.
  
### 2. Move App Code to the Root Directory

- Navigate to your home directory or wherever the repository is stored.
- Move the app code to the root directory:

```bash
mv app_repo /
```

- Ensure the whole repository has been moved to the root, before proceeding.

### 3. Run the waagent command

- The `waagent` command prepares the VM for generalisation by cleaning up user-specific data, including the `adminuser` directory.

```bash
sudo waagent -deprovision+user -force
```

- This will:
  - Remove the `adminuser` account.
  - Clean SSH keys and other user-specific configurations.

### 4. Create the Azure Image

1. Stop the VM first, ensure it is in a deallocated state.
2. Create the image from the **virtual machine overview** page using `capture` by clicking **capture** near the top of the page. Ensure image is named correctly, and image OS is selected as Linux (since it is a Node.js app running on Ubuntu). Click **Review + Create** and complete the image creation if it all looks good.
3. Verify image is created.

### 5. Test the image

- Create a new VM with the image and test the node.js app runs as previously.

- If all looks good, congratulations! You have just deployed a VM with the node.js app using your generalised image! Much easier than all the steps required previously, right?
