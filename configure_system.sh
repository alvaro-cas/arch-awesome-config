#!/bin/bash
# Set color for input and color for output
BLUE="\033[0;36m"
GREEN="\033[0;32m"
RED="\033[0;31m"
NOCOLOR="\033[0m"

usage() {
  echo "Usage: ${0} [-a] [-bcdpqsw]" 1>&2
  echo
  echo 'By default this script will install yay, git'
  echo
  echo '  -a  Install all included. Use this option alone.'
  echo '  -b  Install browsers with custom profiles. Run after reboot. Firefox, Firefox Developer, Brave'
  echo '  -c  Install custom global stock exchange clock and skey utility.'
  echo '  -d  Enable dark mode.'
  echo '  -p  Install productivity tools. Obsidian, onlyoffice, gimp, emacs, signal, audacity'
  echo '  -q  Install virual machine qemu.'
  echo '  -s  Install security tools. Wireshark, openssl, nmap, ufw'
  echo '  -w  Install window manager and desktop configuration. Awesome, lightdm, Xorg, rofi, kitty, lf, neofetch, picom, nvim, audio, bluetooth, node'
  echo
  exit 1
}

check_error() {
  if [[ "${?}" -ne 0 ]]
  then
    echo -e "${RED}${1} encountered an error! Try again!${NOCOLOR}"
    exit 1
  else
    echo -e "${GREEN}${1} installed successfully.${NOCOLOR}"
  fi
}

default() {
  # Create directories
  mkdir -p /home/${USER}/.config
  mkdir -p /home/${USER}/Desktop
  mkdir -p /home/${USER}/Downloads

  # Install basic
  sudo pacman -S --noconfirm git zip unzip

  # Install yay
  git clone https://aur.archlinux.org/yay.git &> /dev/null
  cd yay && makepkg -si --noconfirm
  check_error 'Yay'
  cd ../ && sudo rm -r yay
}

browsers() {
  sudo pacman -S --noconfirm firefox firefox-developer-edition
  check_error 'Firefox'
  yay -S --noconfirm brave-bin
  check_error 'Brave'
  sudo sed -i 's/Exec=brave %U/Exec=brave %U -incognito/' /usr/share/applications/brave-browser.desktop

  # Create firefox profiles
  firefox &> /dev/null &
  PID=$!
  sleep 4
  kill $PID

  sleep 4

  firefox-developer-edition &> /dev/null &
  PID_DEV=$!
  sleep 4
  kill $PID_DEV

  firefox -CreateProfile 'private_firefox'
  firefox-developer-edition -CreateProfile 'private_firefox_dev'

  PRIV_ID=$(ls ~/.mozilla/firefox/ | grep private_firefox$ | cut -d '.' -f 1)
  PRIV_DEV_ID=$(ls ~/.mozilla/firefox/ | grep private_firefox_dev$ | cut -d '.' -f 1)

  tar -xvf ./private_firefox.tar
  tar -xvf ./private_firefox_dev.tar

  cp -r ./private_firefox/* ~/.mozilla/firefox/${PRIV_ID}.private_firefox/
  cp -r ./private_firefox_dev/* ~/.mozilla/firefox/${PRIV_DEV_ID}.private_firefox_dev/

  sed -i "s/^Default.*.default-release$/Default=${PRIV_ID}.private_firefox/" ~/.mozilla/firefox/profiles.ini
  sed -i "s/^Default.*.dev-edition-default$/Default=${PRIV_DEV_ID}.private_firefox_dev/" ~/.mozilla/firefox/profiles.ini
}

custom() {
  # Install skey
  sudo pacman -S --noconfirm android-tools
  check_error 'Android tools'
  sudo mkdir /opt/skey
  sudo cp ./skey/skey.sh /opt/skey
  sudo chown -R $USER: /opt/skey/skey.sh
  sudo chmod u+x /opt/skey/skey.sh

  # Install gloabl clock
  sudo mkdir /opt/global_clock
  sudo cp ./global_clock/clock.sh /opt/global_clock
  sudo chown -R $USER: /opt/global_clock/clock.sh
  sudo chmod u+x /opt/global_clock/clock.sh
}

dark_mode() {
  # Set dark mode
  mkdir -p ~/.config/gtk-3.0
  echo -e '[Settings]\ngtk-application-prefer-dark-theme=1' >> ~/.config/gtk-3.0/settings.ini
  check_error 'Dark mode'
}

productivity() {
  sudo pacman -S --noconfirm obsidian gimp texlive-core emacs \
    signal-desktop audacity
  check_error 'Productivity tools'
  yay -S --noconfirm onlyoffice-bin
  check_error 'Only office'

  # Copy emacs config
  sudo cp -r ./emacs ~/.config/
}

virtual_machine() {
  sudo pacman -S --noconfirm qemu virt-manager dnsmasq vde2 \
    ovmf
  check_error 'Qemu'
  sudo systemctl enable libvirtd
  sudo usermod -G libvirt -a $USER
}

security() {
  sudo pacman -S --noconfirm openssl nmap wireshark-qt ufw
  check_error 'Security tools'
}

window_manager() {
  # Install window manager
  sudo pacman -S --noconfirm lightdm lightdm-gtk-greeter \
    awesome xorg-server neofetch kitty rofi ueberzug \
    vicious man veracrypt keepassxc neovim vim xclip \
    maim peek gifski noto-fonts-emoji noto-fonts-cjk \
    rofi-emoji zbar graphicsmagick ghostscript poppler
  check_error 'Window manager'

  yay -S --noconfirm lf picom-jonaburg-git
  check_error 'Picom and lf'

  # Enable service lightdm
  sudo systemctl enable lightdm.service

  # Configure directories
  sudo cp -r ./kitty/ ./lf/ ./neofetch/ ./picom/ ./rofi/ \
    ./awesome/ ./nvim/ ~/.config/
  sudo cp ./lf/bin/* /usr/bin
  sudo cp ./.bashrc ~/
  sudo cp ./TTF/* /usr/share/fonts

  sudo chown -R $USER: ~/.config/awesome ~/.config/kitty \
    ~/.config/lf ~/.config/neofetch ~/.config/picom \
    ~/.config/rofi /usr/bin/lfub ~/.config/nvim

  sudo chmod u+x ~/.config/awesome/autorun.sh
  sudo chmod u+x /usr/bin/lfub

  # Automatically install plugins
  nvim +'PlugInstall --sync' +qa
  check_error 'Nvim plugins'

  # Install node
  yay -S --noconfirm nvm &> /dev/null
  source /usr/share/nvm/init-nvm.sh &> /dev/null
  check_error 'Nvm'
  nvm install node &> /dev/null
  check_error 'Node'

  # Install files helpers
  sudo pacman -S --noconfirm nemo ntfs-3g
  check_error 'File helpers'
  yay -S --noconfirm spacefm
  check_error 'SpaceFM'

  # Install audio
  sudo pacman -S --noconfirm pulseaudio-alsa alsa-utils \
    playerctl pavucontrol mpv
  check_error 'Audio helpers'

  # Install bluetooth
  sudo pacman -S --noconfirm bluez bluez-utils \
    pulseaudio-bluetooth
  check_error 'Bluetooth helpers'
}

if [[ "${#}" -eq 0 ]]
then
  usage
fi

# Read options and install
while getopts abcdpqsw OPTION
do
	case "${OPTION}" in
		a)
      echo '===> Starting full configuration <==='
      default
      broswers
      custom
      dark_mode
      productivity
      virtual_machine
      security
      window_manager
      exit 0
		;;
		b)
      echo -ne "${BLUE} ===> Configuring browsers <=== ${NOCOLOR}"
      default
      browsers
		;;
		c)
      echo -ne "${BLUE} ===> Installing custom scripts <=== ${NOCOLOR}"
      custom
		;;
		d)
      echo -ne "${BLUE} ===> Configuring dark-mode <=== ${NOCOLOR}"
      dark_mode
		;;
		p)
      echo -ne "${BLUE} ===> Installing productivity tools <=== ${NOCOLOR}"
      default
      productivity
		;;
		q)
      echo -ne "${BLUE} ===> Installing qemu <===' ${NOCOLOR}"
      virtual_machine
		;;
		s)
      echo -ne "${BLUE} ===> Installing security tools <=== ${NOCOLOR}"
      security
		;;
		w)
      echo -ne "${BLUE} ===> Installing window manager <=== ${NOCOLOR}"
      default
      window_manager
		;;
		?)
      usage
		;;
	esac
done

