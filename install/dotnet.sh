#!/usr/bin/env bash

NET_DEB_PATH=$HOME/Downloads/packages-microsoft-prod.deb

echo "Installing Microsoft .NET 9 SDK..."

packages_url=https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb

wget $packages_url -O "$NET_DEB_PATH"

sudo dpkg -i "$NET_DEB_PATH"

sudo apt-get update &&
  sudo apt-get install -y dotnet-sdk-9.0 dotnet-sdk-8.0

# https://github.com/dotnet-outdated/dotnet-outdated
dotnet tool install --global dotnet-outdated-tool

echo "done"
exit 0
