#!/bin/bash
sudo pacman -Sy qemu-desktop libvirt edk2-ovmf virt-manager dnsmasq 

# Get the name of the bridge interface
bridge_name=$(ip route | grep default | awk '{print $5}')

# Create bridge interface br0
nmcli connection add type bridge ifname br0 stp no

# Wait for interface creation
sleep 2

# Add physical interface to bridge
nmcli connection add type bridge-slave ifname $bridge_name master br0

# Bring down existing connection
nmcli connection down "Wired connection 1"

nmcli connection modify bridge-br0 ipv4.addresses "192.168.51.225/24"

nmcli connection modify bridge-br0 ipv4.gateway "192.168.51.1"

nmcli connection modify bridge-br0 ipv4.dns "192.168.51.1"

nmcli connection modify bridge-br0 ipv4.method manual

# Bring up bridge interface
nmcli connection up bridge-br0

# Restart NetworkManager to apply changes
sudo systemctl restart NetworkManager