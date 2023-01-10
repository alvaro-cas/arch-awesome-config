#!/usr/bin/env sh

# Kill all picom insatances
killall -q picom

# Run picom again
picom #--experimental-backends -b
