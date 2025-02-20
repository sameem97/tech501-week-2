#!/bin/bash
# This script will deploy a Node.js app on an Ubuntu 22.04 server

# Exit script if error occurs
set -e

# Set debconf to non-interactive mode to bypass prompts
export DEBIAN_FRONTEND=noninteractive

# Redirect all output and errors to a log file
exec > /var/log/prov-app.log 2>&1

# Update package list and install
echo "updating package list and upgrading packages..."
sudo apt update && sudo apt upgrade -y

# Install nginx
echo "installing nginx..."
sudo apt install nginx -y

# Enable and start nginx if not already running
if ! systemctl is-active --quiet nginx; then
  echo "enabling and starting nginx..."
  sudo systemctl enable nginx
  sudo systemctl start nginx
else
  echo "nginx already running."
fi

# Install npm and nodejs
echo "installing npm and nodejs..."
sudo bash -c "curl -fsSL https://deb.nodesource.com/setup_20.x | bash -"
sudo apt-get install -y nodejs

# Install pm2
echo "installing pm2..."
sudo npm install -g pm2

# Clone the nodejs app repo
if [ ! -d "tech501-sparta-app" ]; then
  echo "cloning the nodejs app repo..."
  git clone https://github.com/sameem97/tech501-sparta-app.git
else
  echo "repository already exists, pulling latest changes..."
  cd tech501-sparta-app
  git pull
  cd ..
fi

# Add nginx reverse proxy if not already configured
if ! grep -q "proxy_pass http://127.0.0.1:3000;" /etc/nginx/sites-available/default; then
  echo "configuring nginx reverse proxy..."
  sudo sed -i 's|try_files.*|proxy_pass http://127.0.0.1:3000;|' /etc/nginx/sites-available/default
else
  echo "nginx reverse proxy already configured."
fi

# Restart nginx
echo "reloading nginx..."
sudo systemctl reload nginx

# Define mongodb connection string
echo "define connection string to mongodb server..."
export DB_HOST=mongodb://<db_private_ip>:27017/posts

# Change directory to the app
echo "changing directory to the app..."
cd tech501-sparta-app/app

# Install npm packages, connect to db, clear and reseed (populate) the database
echo "installing npm packages..."
npm install

# Start the node app in background with pm2 if not already running
if ! pm2 list | grep -q app.js; then
  echo "starting the node app with pm2..."
  pm2 start app.js
else
  echo "node app already running with pm2."
fi

# Check if all commands were successful
if [ $? -eq 0 ]; then
  echo "Deployment successful!"
else
  echo "Deployment failed!"
  exit 1
fi