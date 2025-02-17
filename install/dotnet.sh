#!/usr/bin/env bash

NET_DEB_PATH=$HOME/Downloads/packages-microsoft-prod.deb

echo "Installing Microsoft .NET 9 SDK..."

packages_url=https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb

wget $packages_url -O $NET_DEB_PATH

sudo dpkg -i $NET_DEB_PATH

sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-9.0

echo "done"
exit 0
