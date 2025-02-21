#!/bin/bash
# the script below will be used to initialise the app vm via User Data

# Log all output (both stdout & stderr) to a log file and display in terminal
exec > >(tee -a /var/log/prov-app.log) 2>&1

# navigating into app folder
cd /home/ubuntu/tech501-sparta-app
cd app

#export DB_HOST= correct private IP
export DB_HOST=mongodb://<db_private_ip>:27017/posts

# start the app in the background
pm2 start app.js