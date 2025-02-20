#!/bin/bash
# This script will deploy a MongoDB database on an Ubuntu 22.04 server

# Exit script if error occurs
set -e

# Set debconf to non-interactive mode to bypass prompts
export DEBIAN_FRONTEND=noninteractive

# Redirect all output and errors to a log file
exec > /var/log/prov-db.log 2>&1

# Update package list and install
echo "updating package list and upgrading packages..."
sudo apt update && sudo apt upgrade -y

# Install gnupg and curl
echo "installing gnupg and curl..."
sudo apt install gnupg curl -y

# Import the MongoDB public GPG key if not already imported
if ! sudo gpg --list-keys | grep -q "MongoDB 7.0 Release Signing Key"; then
  echo "importing the MongoDB public GPG key..."
  curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
     sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
     --dearmor
else
  echo "MongoDB public GPG key already imported."
fi

# Create the list file /etc/apt/sources.list.d/mongodb-org-7.0.list if not already created
if [ ! -f /etc/apt/sources.list.d/mongodb-org-7.0.list ]; then
  echo "creating the list file for MongoDB..."
  echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
else
  echo "MongoDB list file already exists."
fi

# Reload apt package database.
echo "reloading apt package database..."
sudo apt update

# install mongo db components
echo "installing MongoDB components..."
sudo apt-get install -y mongodb-org=7.0.6 mongodb-org-database=7.0.6 mongodb-org-server=7.0.6 mongodb-mongosh mongodb-org-mongos=7.0.6 mongodb-org-tools=7.0.6

# enable and start mongodb service
echo "enabling and starting MongoDB service..."
sudo systemctl enable mongod
sudo systemctl start mongod

# Change the bindIp in the mongod.conf file if not already changed
if ! grep -q "bindIp: 0.0.0.0" /etc/mongod.conf; then
  echo "changing the bindIp in the mongod.conf file..."
  sudo sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
else
  echo "bindIp already set to 0.0.0.0 in mongod.conf."
fi

# restart the mongo db service
echo "restarting MongoDB service..."
sleep 5
sudo systemctl restart mongod

# Check if all commands were successful
if [ $? -eq 0 ]; then
  echo "Deployment successful!"
else
  echo "Deployment failed!"
  exit 1
fi
