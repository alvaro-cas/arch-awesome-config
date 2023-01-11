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
blue='\033[0;36m'
grey='\033[0;34m'
white='\033[0;37m'

echo -e "
 $blue  ▄██████▄    $blue  ▄██████▄    $blue  ▄██████▄
 $blue▄$white█▀█$blue██$white█▀█$blue██▄  $blue▄█$white███$blue██$white███$blue█▄  $blue▄█$white███$blue██$white███$blue█▄
 $blue█$white▄▄█$blue██$white▄▄█$blue███  $blue██$white█ █$blue██$white█ █$blue██  $blue██$white█ █$blue██$white█ █$blue██
 $blue████████████  $blue████████████  $blue████████████
 $blue██▀██▀▀██▀██  $blue██▀██▀▀██▀██  $blue██▀██▀▀██▀██
 $blue▀   ▀  ▀   ▀  $blue▀   ▀  ▀   ▀  $blue▀   ▀  ▀   ▀
 "

# Editor of choice
export EDITOR="/usr/bin/nvim"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$HOME/.local/bin:$PATH"
alias lf=lfub
