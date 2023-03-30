#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Ignore case on command 
bind 'set completion-ignore-case on'

alias ls='ls --color=auto'
PS1='\[\033[0;36m\][\w] \[\033[0;36m\]──── ─ \[\033[0;37m\]'

export PATH=$PATH:/home/ryse/.spicetify

# Pacman colorscript
red='\033[0;31m'
grey='\033[0;34m'
white='\033[0;37m'

echo -e "
 $red  ▄██████▄    $red  ▄██████▄    $red  ▄██████▄
 $red▄$white█▀█$red██$white█▀█$red██▄  $red▄█$white███$red██$white███$red█▄  $red▄█$white███$red██$white███$red█▄
 $red█$white▄▄█$red██$white▄▄█$red███  $red██$white█ █$red██$white█ █$red██  $red██$white█ █$red██$white█ █$red██
 $red████████████  $red████████████  $red████████████
 $red██▀██▀▀██▀██  $red██▀██▀▀██▀██  $red██▀██▀▀██▀██
 $red▀   ▀  ▀   ▀  $red▀   ▀  ▀   ▀  $red▀   ▀  ▀   ▀
 "

# Editor of choice
export EDITOR="/usr/bin/nvim"

# NVM start
source /usr/share/nvm/init-nvm.sh

export PATH="$HOME/.local/bin:$PATH"
alias lf=lfub
alias skey=/opt/skey/skey.sh
alias clock="watch -n 1 '/opt/global_clock/clock.sh'"

export PATH="/home/ryse/anaconda3/bin:$PATH"

