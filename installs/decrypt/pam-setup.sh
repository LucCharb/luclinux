#!/bin/bash
# NEED TO INSTALL pam
echo "Insert line 'auth optional pam_exec.so expose_authtok /usr/local/bin/decrypt.sh' on top of /etc/pam.d/system-login"
# auth optional pam_exec.so expose_authtok /usr/local/bin/decrypt.sh
sudo cp /mnt/2TB-2/Linux/Arch/installs/decrypt/decrypt.sh /usr/local/bin/

#echo "This is the new first line" | cat - /mnt/2TB-2/Linux/Arch/installs/decrypt.sh > /mnt/2TB-2/Linux/Arch/installs/decrypt-tmp.sh && mv /mnt/2TB-2/Linux/Arch/installs/decrypt-tmp.sh /mnt/2TB-2/Linux/Arch/installs/decrypt.sh
chmod +x /usr/local/bin/decrypt.sh
chown root:root /usr/local/bin/decrypt.sh
