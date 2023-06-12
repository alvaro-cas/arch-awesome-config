#!/bin/bash

# Add backslash to special characters
clean_xclip=$(xclip -o | sed -e 's/[][)(}{|\/\\^*+.$-~#!\ \"]/\\&/g')

# Send to phone
if ! adb shell input text $clean_xclip; then
  # Clean variable
  clean_xclip="ERROR!"

  # Send error message
  echo -e "\n$clean_xclip"
  echo -e "\nYour text may have an ASCII extended character!"
else
  # Clean variable
  clean_xclip="Transfer complete!"

  # Send enter key
  adb shell input keyevent 66

  # Echo message
  echo $clean_xclip
fi

