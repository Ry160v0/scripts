#!/bin/bash

# Check if at least one IP address or hostname is provided
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <IP_or_Hostname1> <IP_or_Hostname2> ..."
  exit 1
fi

# Iterate over each IP address or hostname provided in the command arguments
for target in "$@"; do
  echo "Scanning $target with nmap -sC -sV..."
  
  # Run nmap with the specified options on each target
  nmap -sC -sV "$target"
  
  echo "Scan for $target completed."
  echo -e "-----------------------------------\n\n"
done

