#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

#root no login
# Check if backup of /etc/passwd already exists
BACKUP_FILE="/etc/passwd.bak"
if [ -f "$BACKUP_FILE" ]; then
  echo "Backup already exists: $BACKUP_FILE"
else
  # Backup /etc/passwd before making changes
  cp /etc/passwd /etc/passwd.bak
  echo "Backup of /etc/passwd created at $BACKUP_FILE"
fi

# Modify /etc/passwd to set root's shell to /sbin/nologin
sed -i 's|^root:.*|root:x:0:0:root:/root:/usr/sbin/nologin|' /etc/passwd

# Check if the modification was successful
if grep -q 'root:x:0:0:root:/root:/sbin/nologin' /etc/passwd; then
  echo "Root shell has been successfully changed to /sbin/nologin."
else
  echo "Failed to change root shell."
fi


#ssh configration

# Backup the original sshd_config file
SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP_FILE="/etc/ssh/sshd_config.bak"
if [ -f "$BACKUP_FILE" ]; then
  echo "Backup already exists: $BACKUP_FILE"
else
  # Backup sshd_config before making changes
  cp "$SSHD_CONFIG" "$BACKUP_FILE"
  if [ $? -eq 0 ]; then
    echo "Backup of $SSHD_CONFIG created at $BACKUP_FILE"
  else
    echo "Failed to create backup. Exiting."
    exit 1
  fi
fi

# Function to uncomment a setting if it exists and is commented
uncomment_or_update_setting() {
  local setting="$1"
  local value="$2"
  local config_file="$3"

  # Check if the line exists but is commented
  if grep -q "^#\s*$setting" "$config_file"; then
    # Uncomment and update the setting
    sed -i "s|^#\s*$setting.*|$setting $value|" "$config_file"
  elif grep -q "^$setting" "$config_file"; then
    # Update the existing setting
    sed -i "s|^$setting.*|$setting $value|" "$config_file"
  else
    # Add the setting if it does not exist
    echo "$setting $value" >> "$config_file"
  fi
}

# Function to comment out a specific line in sshd_config
comment_out_setting() {
  local setting="$1"
  local config_file="$2"

  if grep -q "^$setting" "$config_file"; then
    # Comment out the setting if it exists
    sed -i "s|^$setting|#&|" "$config_file"
  fi
}

# Applying the requested security settings


# Disable root login
uncomment_or_update_setting "PermitRootLogin" "no" "$SSHD_CONFIG"

# Enable public key authentication
uncomment_or_update_setting "PubkeyAuthentication" "yes" "$SSHD_CONFIG"

# Set the file for authorized keys (default location)
uncomment_or_update_setting "AuthorizedKeysFile" ".ssh/authorized_keys" "$SSHD_CONFIG"

# Limit the maximum number of authentication attempts to 3
uncomment_or_update_setting "MaxAuthTries" "3" "$SSHD_CONFIG"

# Set the login grace time to 20 seconds
uncomment_or_update_setting "LoginGraceTime" "20" "$SSHD_CONFIG"

# Disable empty passwords
uncomment_or_update_setting "PermitEmptyPasswords" "no" "$SSHD_CONFIG"

# Enable challenge-response authentication
uncomment_or_update_setting "ChallengeResponseAuthentication" "yes" "$SSHD_CONFIG"

# Disable Kerberos authentication
uncomment_or_update_setting "KerberosAuthentication" "no" "$SSHD_CONFIG"

# Disable GSSAPI authentication
uncomment_or_update_setting "GSSAPIAuthentication" "no" "$SSHD_CONFIG"

# Comment out the "Subsystem" line
comment_out_setting "Subsystem" "$SSHD_CONFIG"

# Disable X11 forwarding
uncomment_or_update_setting "X11Forwarding" "no" "$SSHD_CONFIG"

# Disable user environment variable passing
uncomment_or_update_setting "PermitUserEnvironment" "no" "$SSHD_CONFIG"

# Comment out the "AcceptEnv" line
comment_out_setting "AcceptEnv" "$SSHD_CONFIG"

# Restart the SSH service to apply the changes
systemctl restart sshd

if [ $? -eq 0 ]; then
  echo "SSH configuration has been successfully updated."
else
  echo "Failed to restart SSH service. Please check the configuration."
  exit 1
fi
