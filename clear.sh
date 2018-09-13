#!/bin/bash

# usage PASSWORD=xxxx ./clear.sh 
sudo rabbitmqctl stop_app 
sudo rabbitmqctl reset 
sudo rabbitmqctl start_app
sleep 1
sudo rabbitmqctl add_user deploy $PASSWORD
sudo rabbitmqctl set_user_tags deploy administrator
sudo rabbitmqctl set_permissions -p / deploy  ".*" ".*" ".*"
