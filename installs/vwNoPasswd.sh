#! /bin/zsh

sudo groupadd --system libvirtd
sudo usermod -a -G libvirtd $(whoami)
newgrp libvirtd
id $(whoami)
