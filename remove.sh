#!/bin/bash

# Ensure script runs as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

echo "Starting removal process..."

###################################################################################
echo "############################## Stopping Services ##############################"
###################################################################################

# Stop and disable spec service if it exists
if systemctl list-units --full -all | grep -q "spec.service"; then
    systemctl stop spec
    systemctl disable spec
    rm -f /etc/systemd/system/spec.service
    systemctl daemon-reload
    echo "Stopped and removed spec service."
fi

# Stop and disable MongoDB
if systemctl list-units --full -all | grep -q "mongod.service"; then
    systemctl stop mongod
    systemctl disable mongod
    echo "Stopped MongoDB service."
fi

# Stop and disable Nginx
if systemctl list-units --full -all | grep -q "nginx.service"; then
    systemctl stop nginx
    systemctl disable nginx
    echo "Stopped Nginx service."
fi

###################################################################################
echo "############################## Removing Node.js ##############################"
###################################################################################

# Find and kill the Node.js process if running
pid=$(ps -ef | grep "index.js" | grep -v grep | awk '{print $2}')
if [ -n "$pid" ]; then
    kill -9 "$pid"
    echo "Stopped Node.js process (PID: $pid)."
else
    echo "No running Node.js process found."
fi

# Remove Node.js and related packages
dnf remove -y nodejs
rm -rf /usr/lib/node_modules
rm -rf /root/.npm

###################################################################################
echo "############################## Removing MongoDB ##############################"
###################################################################################

# Remove MongoDB packages
dnf remove -y mongodb-org
rm -rf /var/lib/mongo
rm -rf /var/log/mongodb
rm -f /etc/yum.repos.d/mongodb-org-7.0.repo

###################################################################################
echo "############################## Removing Nginx ##############################"
###################################################################################

# Remove Nginx and related files
dnf remove -y nginx
rm -rf /etc/nginx
rm -rf /var/log/nginx
rm -rf /var/www/html

###################################################################################
echo "############################## Removing Application Files ##############################"
###################################################################################

# Remove the application and user
userdel -r spec 2>/dev/null
rm -rf /home/spec

# Remove any remaining log files
rm -f /root/node.logs /root/run.log

echo "Cleanup completed successfully."
