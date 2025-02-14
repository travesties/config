#!/usr/bin/env bash

# Use first argument as the interval timer. Default to 55 seconds.
while sleep "${1:-55}"
do
    # Build list of dbus services that implement the org.mpris.MediaPlayer2 interface
    media_players=$(dbus-send \
        --print-reply \
        --dest=org.freedesktop.DBus  \
        /org/freedesktop/DBus \
        org.freedesktop.DBus.ListNames \
        | egrep -o '"org.mpris.MediaPlayer2.*"' \
        | sed 's/"//g')

    # Search media players for a playback status of "Playing"
    for player in $media_players; do
        status=$(\
            dbus-send \
                --print-reply=literal \
                --dest=$player \
                /org/mpris/MediaPlayer2 \
                org.freedesktop.DBus.Properties.Get \
                string:org.mpris.MediaPlayer2.Player \
                string:PlaybackStatus \
        )

        # Disable screen saver if media is playing
        if [[ "$status" == *"Playing"* ]]; then
            xset s reset
            break
        fi
    done
done
