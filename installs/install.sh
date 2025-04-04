#!/bin/bash

# Define package lists
# wine, fonts, media, apps, printer,system, base, test, all
declare -A packages
packages[1]="wine winetricks wine-stable-mono wine-gecko bottles-git lutris"
packages[2]="ttf-ms-win11-auto noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra"
packages[3]="audacity gimp inkscape xnviewmp mpv phonon-qt6-mpv-git python-mutagen "
packages[4]="thunderbird kalk libreoffice-fresh nomachine visual-studio-code-bin pfetch fastfetch nomachine"
packages[5]="epson-inkjet-printer-202101w epson-inkjet-printer-escpr epson-inkjet-printer-escpr2 epson-printer-utility cups xsane-git"
packages[6]="gnome-disk-utility kwalletmanager gpu-passthrough-manager timeshift kdeconnect btop"
packages[7]="kitty kitty-terminfo zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting tmux oh-my-zsh-git eza rsync veracrypt librewolf-bin samba reflector yazi pfetch fastfetch"
packages[8]="gimp-plugin-beautify gimp-plugin-bimp gimp-plugin-export-layers gimp-plugin-gmic gimp-plugin-resynthesizer gimp-plugin-saveforweb"
packages[9]="dosfstools ntfs-3g exfat-utils btrfs-progs xfsprogs f2fs-tools udftools"

echome(){
    clear &&
    echo "                Options are:               Q - quit   "       &&
    echo "########################################################################" &&
    echo " 0 - all      1 - wine    2 - fonts  3 - media-tools  4 - apps"            &&
    echo " 5 - printer  6 - system  7 - base   8 - Gimp Addons  9 - System Files "   &&
    echo " 10 - VM                                      11 - Create Bridge     "      &&
    echo "########################################################################"
}


# Check if yay and git are installed.
check_yay_installed() {
  if ! git --version &> /dev/null; then  
      echo "Git is not installed. Installing..."
      sudo pacman -S --noconfirm --needed git
  fi

  if ! yay --version &> /dev/null; then
    echo "Yay is not installed. Installing..."
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
    rm -rf yay
  fi
}

# Install packages from list given as arguments.
install_packages() {
  echo "This will install "$@""
  read -p "You ok with that? " confirm
  [ "$confirm" = "y" ] || [ "$confirm" = "Y" ] &&
  echo "Installing "$@""
  yay -S --noconfirm --needed "$@"
}

create_bridge(){
  # Get the name of the bridge interface
  bridge_name=$(ip route | grep default | awk '{print $5}')
  # Create bridge interface br0
  sudo nmcli connection add type bridge ifname br0 stp no
  sleep 2  # Wait for interface creation
  # Add physical interface to bridge
  sudo nmcli connection add type bridge-slave ifname $bridge_name master br0
  # Bring down existing connection
  sudo nmcli connection down "Wired connection 1"
 
  # Set static IP
  read -p "Do you want a static IP? (Y/n) " ipsel
  if [ "$ipsel" = "y" ] || [ "$ipsel" = "Y" ]; then
    read -p "Enter last 3 digits of: 192.168.51." ip
    read -p "You've entered: $ip , confirm? (Y/n) " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then 
      sudo nmcli connection modify bridge-br0 ipv4.addresses "192.168.51.$ip/24"
      sudo nmcli connection modify bridge-br0 ipv4.gateway "192.168.51.1"
      sudo nmcli connection modify bridge-br0 ipv4.dns "192.168.51.1"
      sudo nmcli connection modify bridge-br0 ipv4.method manual
    fi
  fi       

  # Bring up bridge interface
  sudo nmcli connection up bridge-br0

  # Restart NetworkManager to apply changes
  sudo systemctl restart NetworkManager
}

# Parse command line arguments, and install packages accordingly.
# If option is not recognized, exit with display message.
parse_args() {
  if [ "$cat" != 0 ] && [ -z "${packages[$cat]}" ]; then
      echo "Invalid option: $cat"
      exit
  elif  [ "$cat" = 0 ]; then
    for category in "${!packages[@]}"; do
      install_packages ${packages[$category]}
    done
    install_vm_kit
  else
    install_packages ${packages[$cat]}
  fi
}
install_vm_kit(){
  sudo pacman -S --noconfirm --needed qemu-desktop libvirt edk2-ovmf virt-manager dnsmasq
}
  
echome
read -p "Enter number or Q to quit: " cat
# [ "$cat" = "q" ] || [ "$cat" = "Q" ] && clear && exit
case $cat in
    q | Q)
        clear
        exit
        ;;
    0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9)
       # install packages
        check_yay_installed
        parse_args "$cat"
        ;;
    10)
        # Install VM
        install_vm_kit
        ;;
    11)
        create_bridge # Create bridge with static IP
        ;;
    *)
        echo "Invalid option: $cat"
        exit
        ;;
esac
