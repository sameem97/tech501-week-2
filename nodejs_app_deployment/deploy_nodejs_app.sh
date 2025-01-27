#!/bin/bash

# Update package list and install
sudo apt update && sudo apt upgrade -y

# Install nginx
sudo apt install nginx -y

# Enable nginx
sudo apt enable nginx

# Install npm and nodejs
sudo DEBIAN_FRONTEND=noninteractive bash -c "curl -fsSL https://deb.nodesource.com/setup_20.x | bash -" && \
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs

# Clone the nodejs app repo
git clone https://github.com/sameem97/tech501-sparta-app.git

# Change directory to the app
cd tech501-sparta-app/app

# Install npm packages
npm install

# Start the node app
npm start

