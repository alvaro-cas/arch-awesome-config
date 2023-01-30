#!/bin/bash
# Set color for input and color for output
BLUE="\033[0;36m"
GREEN="\033[0;32m"
RED="\033[0;31m"
NOCOLOR="\033[0m"

echo -ne "${BLUE}Install Awesome and applications configured? [y/N]: ${NOCOLOR}"
read "answer"
if [ "$answer" == "Y" -o "$answer" == "y" ]
then

    # Install windows manager and helpers
    sudo pacman -S --noconfirm git lightdm lightdm-gtk-greeter awesome xorg-server
    sudo systemctl enable lightdm.service

    # Install yay
    git clone https://aur.archlinux.org/yay.git
    cd yay && makepkg -si
    cd ../ && sudo rm -r yay

    # Install pacman applications
    sudo pacman -S --noconfirm neofetch pulseaudio-alsa alsa-utils playerctl zip unzip signal-desktop kitty firefox rofi xclip firefox-developer-edition nemo veracrypt keepassxc ueberzug graphicsmagick ghostscript obsidian ntfs-3g maim peek gifski zbar iw noto-fonts-emoji noto-fonts-cjk rofi-emoji xdotool emacs neovim vicious poppler texlive-most bluez bluez-utils pulseaudio-bluetooth

    # Install yay applications
    yay -S --noconfirm onlyoffice-bin lf picom-jonaburg-git spacefm nvm spotify

    # Install node
    source /usr/share/nvm/init-nvm.sh
    nvm install node

    # Copy configuration to ~/.config folder
    mkdir -p /home/${username}/.config
    sudo cp ./TTF/* /usr/share/fonts
    sudo cp -r ./emacs ./kitty/ ./lf/ ./neofetch/ ./nvim/ ./picom/ ./rofi/ ./awesome/ ~/.config/
    sudo cp ./.bashrc ~/
    sudo cp ./lf/bin/* /usr/bin

    # Change ownership
    sudo chown -R $USER: ~/.config/awesome ~/.config/kitty ~/.config/lf ~/.config/neofetch ~/.config/nvim ~/.config/picom ~/.config/rofi /usr/bin/lfub

    # Add app configuration
    sudo chmod u+x ~/.config/awesome/autorun.sh
    sudo chmod u+x /usr/bin/lfub
    nvim +'PlugInstall --sync' +qa

    # Change wifi and battery
    echo -e "${GREEN}### Wifi interface ###\n${NOCOLOR}"
    nmcli device
    echo -ne "\n${BLUE}Name of wifi interface: ${NOCOLOR}"
    read interface
    sed -i "s/wlo1/$interface/g" ~/.config/awesome/rc.lua

    echo -e "${GREEN}### Power Supply ###\n${NOCOLOR}"
    ls /sys/class/power_supply
    echo -ne "\n${BLUE}Name of battery: ${NOCOLOR}"
    read battery
    sed -i "s/BAT0/$battery/g" ~/.config/awesome/rc.lua

    reboot

else
  echo -e "${RED}### Skipped Window Manager and App configuration ###${NOCOLOR}"
fi

