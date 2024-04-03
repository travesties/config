#!/bin/bash

# Set up script for installing my workflow on a new machine.
mkdir -p $XDG_DATA_HOME
mkdir -p $XDG_CONFIG_HOME
mkdir -p $XDG_STATE_HOME
mkdir -p $XDG_BIN_HOME
mkdir -p $XDG_OPT_HOME
mkdir -p $GOPATH
mkdir -p $GOBIN

# Create symbolic links between this repo and home
ln -sTf "$PWD/.bashrc" "$HOME/.bashrc"
ln -sTf "$PWD/nvim" "$XDG_CONFIG_HOME/nvim"

# Install all necessary packages for workflow setup
apt install man-db curl xclip python3 python3-pip python3-venv make unzip ripgrep fontconfig rlwrap xsel

### FONTS
echo "########## Installing Hack Nerd Font ##########"
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
unzip Hack.zip -d Hack

mkdir -p $XDG_DATA_HOME/fonts
mv Hack/*.ttf $XDG_DATA_HOME/fonts
fc-cache -f -v
rm -f Hack.zip
rm -rf Hack

### GO
echo "########## Installing Golang ##########"
rm -rf "$HOME/.local/go"
curl -LO https://go.dev/dl/go1.22.1.linux-amd64.tar.gz
tar -C "$HOME/.local" -xzf go1.22.1.linux-amd64.tar.gz
rm -f go1.22.1.linux-amd64.tar.gz

go install github.com/go-delve/delve/cmd/dlv@latest
ln -sTf "$GOBIN/dlv" "$XDG_BIN_HOME/dlv"

### NODE
echo "########## Installing Node.js and NVM ##########"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source .bashrc
nvm install --lts

### cheat.sh
echo "########## Installing cheat.sh ##########"
curl -s https://cht.sh/:cht.sh | tee $XDG_BIN_HOME/cht.sh && chmod +x $XDG_BIN_HOME/cht.sh

### lazygit
echo "########## Installing Lazygit ##########"
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
install lazygit $XDG_BIN_HOME
rm lazygit lazygit.tar.gz

### NEOVIM
echo "########## Installing Neovim ##########"
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
rm -rf $XDG_OPT_HOME/nvim-linux64
tar -C $XDG_OPT_HOME -xzf nvim-linux64.tar.gz
rm nvim-linux64.tar.gz

# set up python virtual environment for nvim
echo "########## Creating Neovim Virtual Python Environment ##########"
cd nvim
python3 -m venv nvim_pyenv
source nvim_pyenv/bin/activate
pip install -r requirements.txt
deactivate
cd ..

source .bashrc
echo "########## Installation Complete ##########"
