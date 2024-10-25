#!/bin/bash

# Check if the script is being run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Create the target directory if it doesn't exist
mkdir -p /var/srjk

# Copy specified directories and files to /var/srjk
echo "Copying files and directories to /var/srjk..."

cp -r /etc /var/srjk
echo "Copied /etc to /var/srjk"

cp -r /var/www /var/srjk
echo "Copied /var/www to /var/srjk"

cp -r /etc/apache2 /var/srjk
echo "Copied /etc/apache2 to /var/srjk"

cp -r /etc/mysql /var/srjk
echo "Copied /etc/mysql to /var/srjk"

cp /etc/bash.bashrc /var/srjk
echo "Copied /etc/bash.bashrc to /var/srjk"

cp -r /usr/bin /var/srjk
echo "Copied /usr/bin to /var/srjk"

cp -r /usr/sbin /var/srjk
echo "Copied /usr/sbin to /var/srjk"

cp -r /lib/systemd/system /var/srjk
echo "Copied /lib/systemd/system to /var/srjk"

echo "All files and directories have been successfully copied to /var/srjk."
