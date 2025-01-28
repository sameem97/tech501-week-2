#!/bin/bash
# This script will deploy a MongoDB database on an Ubuntu 20.04 server

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

# Reload the package database.
sudo apt update

# install mongo db components
sudo apt-get install -y mongodb-org=7.0.6 mongodb-org-database=7.0.6 mongodb-org-server=7.0.6 mongodb-mongosh mongodb-org-mongos=7.0.6 mongodb-org-tools=7.0.6

# enable mongodb service
sudo systemctl enable mongod

# start mongodb service
sudo systemctl start mongod

# change the bindIp in the mongod.conf file
sudo nano /etc/mongod.conf

# restart the mongo db service
sudo systemctl restart mongod

# ssh into the nodejs app vm, run the below commands

# export the DB_host environment variable
export DB_HOST=mongodb://<db_private_ip>:27017/posts

# check db connection, clearing and reseeding (populating) the database 
npm install

# start the nodejs app, check app and database records are displaying
npm start