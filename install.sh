echo -e "Hello, $(whoami)!"
# Ask to continue
echo -n "Install configuration files? (doing this will erase any previous configuration)"

read "answer"

if [ "$answer" == "Y" -o "$answer" == "y" ]
then
  # Install pacman applications
  sudo pacman -S neofetch pulseaudio-alsa alsa-utils playerctl zip unzip signal-desktop kitty firefox rofi xclip firefox-developer-edition nemo veracrypt keepassxc ueberzug graphicsmagick ghostscript obsidian ntfs-3g maim peek gifski zbar iw noto-fonts-emoji noto-fonts-cjk rofi-emoji xdotool emacs neovim

  # Install yay applications
  yay -S onlyoffice-bin lf picom-jonaburg-git spacefm nvm spotify

  # Copy configuration to ~/.config folder
  sudo cp ./TTF/* /usr/share/fonts
  sudo cp -r ./kitty/ ./lf/ ./neofetch/ ./nvim/ ./picom/ ./rofi/ ./awesome/ ~/.config/
  sudo cp ./.bashrc ~/
  sudo cp ./lf/bin/* /usr/bin
else
  echo "Come back later! :)"
fi
