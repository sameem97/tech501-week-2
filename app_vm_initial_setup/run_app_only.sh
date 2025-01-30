#!/bin/bash
# the script below will be used to initialise the app vm via User Data

# navigating into app folder
cd tech501-sparta-app/app

#export DB_HOST= correct private IP
export DB_HOST=mongodb://10.0.3.4:27017/posts

# start the app in the background
pm2 start app.js