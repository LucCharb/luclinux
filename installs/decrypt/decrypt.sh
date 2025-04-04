#!/bin/bash

# Your script that decrypts the drives
DECRYPT_SCRIPT="/home/luke/decrypt"

# Read the login password from stdin (provided by PAM)
read -r PASSWORD

# Pass the password to your decryption script
echo "$PASSWORD" | "$DECRYPT_SCRIPT"

# (Optional) Securely erase the password from memory
unset PASSWORD
