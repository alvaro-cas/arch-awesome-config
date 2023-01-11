This script assumes you have an Arch installation finished and installed software / or similar:
`lightdm`, `lightdm-gtk-greeter`, `awesome`, `xorg-server`, `base-devel`, `yay`

If you need a fast guide, refer to my [Medium post](https://medium.com/@alvaro-cas/arch-linux-and-my-customization-37b15c716c7?source=friends_link&sk=b2845dfc411ae398761f8e2ed5cee2b2).

## Installation
```bash
git clone https://github.com/alvaro-cas/arch-awesome-config
cd ./arch-awesome-config
chmod u+x ./install.sh
./install.sh
```

### Nvim Installation
Install nvim plugins by entering nvim and doing:
```bash
:PlugInstall
```
Restart nvim

### Change wifi interface
```bash
nmcli device
```
Check the one with 'STATE' connected
```bash
nvim ~/.config/awesome/rc.lua
```
Use search command in nvim
```Neovim
/wifiiw
```
Press Enter and change "wlo1" to "your_connected_device"

## Preview 
![](https://github.com/alvaro-cas/arch-awesome-config/blob/main/assets/full_desktop.gif?raw=true)

## The Bar
![](https://github.com/alvaro-cas/arch-awesome-config/blob/main/assets/bar_left.png?raw=true)
![](https://github.com/alvaro-cas/arch-awesome-config/blob/main/assets/bar_right.png?raw=true)

## System Tray
![](https://github.com/alvaro-cas/arch-awesome-config/blob/main/assets/tray.png?raw=true)

## Terminal
![](https://github.com/alvaro-cas/arch-awesome-config/blob/main/assets/bashrc.png?raw=true)

## Neofetch
![](https://github.com/alvaro-cas/arch-awesome-config/blob/main/assets/neofetch.png?raw=true)

## Picom
![](https://github.com/alvaro-cas/arch-awesome-config/blob/main/assets/picom.gif?raw=true)

## Nvim and LF
![](https://github.com/alvaro-cas/arch-awesome-config/blob/main/assets/full_desktop_lf.png?raw=true)

## Rofi and Wallpaper
![](https://github.com/alvaro-cas/arch-awesome-config/blob/main/assets/rofi.png?raw=true)

## Basic Hotkeys
![](https://github.com/alvaro-cas/arch-awesome-config/blob/main/assets/commands.png?raw=true)

## Do you find this useful?

<a href="https://www.buymeacoffee.com/alvaro.cas"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=alvaro.cas&button_colour=FFDD00&font_colour=000000&font_family=Inter&outline_colour=000000&coffee_colour=ffffff"></a>

Hey, thank you for your support!

***

## MIT LICENSE
Review the [LICENSE](https://github.com/alvaro-cas/arch-awesome-config/blob/main/LICENSE)

