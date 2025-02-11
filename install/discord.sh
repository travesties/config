#!/bin/bash

DISCORD_DEB_PATH=~/Downloads/discord.deb

echo "Getting discord latest stable..."

if command -v discord &> /dev/null; then
    sudo apt -y remove discord
fi

response_code=$(curl -s -o $DISCORD_DEB_PATH -w "%{http_code}" -L https://discord.com/api/download/stable?platform=linux&format=deb)

if [[ $response_code != 200 ]]; then
    echo "Download request failed with response code $response_code"
    exit 1
fi

sudo dpkg -i $DISCORD_DEB_PATH
rm $DISCORD_DEB_PATH

exit 0

