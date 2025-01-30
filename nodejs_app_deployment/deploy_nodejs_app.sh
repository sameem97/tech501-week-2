#!/bin/bash

# Update package list and install
sudo apt update && sudo apt upgrade -y

# Install nginx
sudo apt install nginx -y

# Enable and start nginx
sudo apt enable nginx
sudo systemctl start nginx

# Install npm and nodejs
sudo DEBIAN_FRONTEND=noninteractive bash -c "curl -fsSL https://deb.nodesource.com/setup_20.x | bash -" && \
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs

# Install pm2
sudo npm install -g pm2

# Clone the nodejs app repo
git clone https://github.com/sameem97/tech501-sparta-app.git

# Check if git clone was successful
if [ $? -ne 0 ]; then
  echo "Failed to clone repository!"
  exit 1
fi

# Connect to the mongodb server
export DB_HOST=mongodb://10.0.3.4:27017/posts

# Change directory to the app
cd tech501-sparta-app/app

# Install npm packages, check db connection, clearing and reseeding (populating) the database 
npm install

# Start the node app in backround with pm2
pm2 start app.js

# Check if all commands were successful
if [ $? -eq 0 ]; then
  echo "Deployment successful!"
else
  echo "Deployment failed!"
  exit 1
fi