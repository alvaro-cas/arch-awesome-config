echo -e "Hello, $(whoami)!"
# Ask to continue
echo -e "Install configuration files?"
echo -n "(doing this will erase any previous configuration) [y/N] "

read "answer"

if [ "$answer" == "Y" -o "$answer" == "y" ]
then
  # Install pacman applications
  sudo pacman --noconfirm -S neofetch pulseaudio-alsa alsa-utils playerctl zip unzip signal-desktop kitty firefox rofi xclip firefox-developer-edition nemo veracrypt keepassxc ueberzug graphicsmagick ghostscript obsidian ntfs-3g maim peek gifski zbar iw noto-fonts-emoji noto-fonts-cjk rofi-emoji xdotool emacs neovim vicious

  # Install yay applications
  yay --noconfirm -S onlyoffice-bin lf picom-jonaburg-git spacefm nvm spotify

  # Install node
  source /usr/share/nvm/init-nvm.sh
  nvm install node

  # Copy configuration to ~/.config folder
  sudo cp ./TTF/* /usr/share/fonts
  sudo cp -r ./kitty/ ./lf/ ./neofetch/ ./nvim/ ./picom/ ./rofi/ ./awesome/ ~/.config/
  sudo cp ./.bashrc ~/
  sudo cp ./lf/bin/* /usr/bin

  # Change ownership
  chown -R $USER: ~/.config/awesome ~/.config/kitty ~/.config/lf ~/.config/neofetch ~/.config/nvim ~/.config/picom ~/.config/rofi /usr/bin/lfub

  chmod u+x /usr/bin/lfub

  echo "Done :)"
else
  echo "Come back later! :)"
fi
