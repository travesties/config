#!/bin/bash

# Set up script for installing my workflow on a new machine.

# TODO: Determine if I need to source my bashrc before running steps

read -p "GitHub Email Address:" GITHUBEMAIL

# Create symbolic links between this repo and home
ln -sf "$PWD/.bashrc" "$HOME/.bashrc"
ln -sf "$PWD/.bash_aliases" "$HOME/.bash_aliases"
ln -sf "$PWD/nvim" "$XDG_CONFIG_HOME/nvim"

source $HOME/.bashrc

# Install all necessary packages for workflow setup
sudo apt-get update && sudo apt-get upgrade
sudo apt install man-db curl xclip python3 python3-pip python3-venv make unzip ripgrep fontconfig rlwrap xsel

### GIT

# add github.com to known_hosts
mkdir ~/.ssh && touch ~/.ssh/known_hosts
ssh-keyscan github.com >> ~/.ssh/known_hosts

# create ssh key pair
ssh-keygen -t ed25519 -C $GITHUBEMAIL

# add key to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

### FONTS
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
unzip Hack.zip -d Hack
mv ./Hack/*.ttf /usr/local/share/fonts
fc-cache -f -v
rm -rf ./Hack

### GO
curl -LO https://go.dev/dl/go1.22.1.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.22.1.linux-amd64.tar.gz
rm go1.22.1.linux-amd64.tar.gz2

go install github.com/go-delve/delve/cmd/dlv@latest
ln -s ~/go/bin/dlv /usr/local/bin/dlv

### NODE
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install --lts

### cheat.sh
curl -s https://cht.sh/:cht.sh | sudo tee /usr/local/bin/cht.sh && sudo chmod +x /usr/local/bin/cht.sh

### lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit lazygit.tar.gz

### NEOVIM
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
rm nvim-linux64.tar.gz

# set up python virtual environment for nvim
cd nvim
python3 -m venv nvim_pyenv
source nvim_pyenv/bin/activate
pip install -r requirements.txt
deactivate
cd ..
