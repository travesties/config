#!/bin/bash

echo "Getting neovim latest..."

NVIM_TAR_PATH=$HOME/Downloads/

# Remove existing install
rm -rf $XDG_OPT_HOME/nvim-linux64

# Download latest
latest_url=https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
response_code=$(curl -s -o $NVIM_TAR_PATH -w "%{http_code}" -L $latest_url)

if [[ $response_code != 200 ]]; then
	echo "Download request failed with response code $response_code"
	exit 1
fi


tar -C $XDG_OPT_HOME -xzf $NVIM_TAR_PATH/nvim-linux64.tar.gz
rm $NVIM_TAR_PATH/nvim-linux64.tar.gz

echo "done"
exit 0
