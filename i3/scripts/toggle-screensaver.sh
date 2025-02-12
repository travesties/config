#!/usr/bin/env bash

# Extract timeout value in Screen Saver sections of xset info
current_timeout=$(xset q | grep -A2 "Screen Saver" | grep -oP "(?<=timeout:  )[^ ]+")

if [[ "$current_timeout" == "0" ]]; then
    msg="Screensaver Timeout: ACTIVE"
    xset s on
else
    msg="Screensaver Timeout: PAUSED"
    xset s off
fi

notify-send -t 2000 "$msg"
