#!/bin/bash
# This script will deploy a MongoDB database on an Ubuntu 22.04 server

# Update package list and install
sudo apt update && sudo apt upgrade -y

# Install gnupg and curl
sudo apt install gnupg curl -y

# Import the MongoDB public GPG key
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor

# Create the list file /etc/apt/sources.list.d/mongodb-org-7.0.list for your version of Ubuntu
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Reload apt package database.
sudo apt update

# Preconfigure debconf to avoid interactive prompts
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections

# install mongo db components
sudo apt-get install -y mongodb-org=7.0.6 mongodb-org-database=7.0.6 mongodb-org-server=7.0.6 mongodb-mongosh mongodb-org-mongos=7.0.6 mongodb-org-tools=7.0.6

# enable and start mongodb service
sudo systemctl enable mongod
sudo systemctl start mongod

# change the bindIp in the mongod.conf file
sudo sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf

# restart the mongo db service
sleep 5
sudo systemctl restart mongod
