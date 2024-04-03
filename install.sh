#!/bin/bash
INSTALL_PATH=$PWD

echo
echo "Let's setup your environment!"

sudo apt-get update && sudo apt-get upgrade
sudo apt -y install ssh git vim curl

read -p "Enter your GitHub username: " ghuser
read -p "Enter your GitHub email: " ghemail

git config --global user.name "$ghuser"
git config --global user.email "$ghemail"

mkdir -p $HOME/.ssh && touch $HOME/.ssh/known_hosts

# Only keyscan github.com if it hasn't already been done
if [ ! -s $HOME/.ssh/known_hosts ]; then
	ssh-keyscan github.com >> $HOME/.ssh/known_hosts
fi

# Create ssh key if none exist
if [ ! -s $HOME/.ssh/"id_$ghuser" ]; then
	ssh-keygen -t ed25519 -C $ghemail -f $HOME/.ssh/"id_$ghuser"
fi

[ -n "$SSH_AUTH_SOCK" ] || eval "$(ssh-agent)"
ssh-add $HOME/.ssh/"id_$ghuser"

echo
cat $HOME/.ssh/"id_$ghuser".pub
echo "Have you added the public key to your GitHub account? (y/n) "
while true; do
	read -n 1 key
	if [ $key == "y" ] || [ $key == "Y" ]; then
		break
	elif [ $key == "n" ] || [ $key == "N" ]; then
		echo "You must add the public key to continue. Quitting..."
		exit 0
	fi
done

# Create repo structre and clone config repo
if [ ! -d $HOME/repos/github.com/$ghuser ]; then
	mkdir -p $HOME/repos/github.com/$ghuser
	git clone git@github.com:$ghuser/config.git $HOME/repos/github.com/$ghuser/config
fi

# Run config setup script
cd $HOME/repos/github.com/$ghuser/config
source .bashrc

# Set up script for installing my workflow on a new machine.
if [ -z "${XDG_DATA_HOME}" ]; then
	echo "XDG paths not configured property. Abort."
	exit 1
fi

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"
mkdir -p "$XDG_STATE_HOME"
mkdir -p "$XDG_BIN_HOME"
mkdir -p "$XDG_OPT_HOME"
mkdir -p "$GOPATH"
mkdir -p "$GOBIN"

# Create symbolic links between this repo and home
ln -sTf "$PWD/.bashrc" "$HOME/.bashrc"
ln -sTf "$PWD/nvim" "$XDG_CONFIG_HOME/nvim"

# Install all necessary packages for workflow setup
sudo apt -y install man-db xclip python3 python3-pip python3-venv make unzip ripgrep fontconfig rlwrap xsel

### FONTS
if [[ $(ls $XDG_DATA_HOME/fonts/HackNerdFont* 2>/dev/null) == "" ]]; then
	echo
	echo "########## Installing Hack Nerd Font ##########"
	curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
	unzip Hack.zip -d Hack
	
	mkdir -p $XDG_DATA_HOME/fonts
	mv Hack/*.ttf $XDG_DATA_HOME/fonts
	fc-cache -f -v
	rm -f Hack.zip
	rm -rf Hack
fi

### GO
echo
echo "########## Installing Golang ##########"
rm -rf "$HOME/.local/go"
curl -LO https://go.dev/dl/go1.22.1.linux-amd64.tar.gz
tar -C "$HOME/.local" -xzf go1.22.1.linux-amd64.tar.gz
rm -f go1.22.1.linux-amd64.tar.gz

go install github.com/go-delve/delve/cmd/dlv@latest
ln -sTf "$GOBIN/dlv" "$XDG_BIN_HOME/dlv"

### NODE
echo
echo "########## Installing Node.js and NVM ##########"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source .bashrc
nvm install --lts

### cheat.sh
if [ ! -f $XDG_BIN_HOME/cht.sh ]; then
	echo
	echo "########## Installing cheat.sh ##########"
	curl -s https://cht.sh/:cht.sh | tee $XDG_BIN_HOME/cht.sh && chmod +x $XDG_BIN_HOME/cht.sh
fi

### lazygit
if [ ! -f $XDG_BIN_HOM/lazygit ]; then
	echo
	echo "########## Installing Lazygit ##########"
	LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
	curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
	tar xf lazygit.tar.gz lazygit
	install lazygit $XDG_BIN_HOME
	rm lazygit lazygit.tar.gz
fi

### NEOVIM
if [ ! -d "$XDG_OPT_HOME/nvim-linux64" ]; then
	echo
	echo "########## Installing Neovim ##########"
	curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
	rm -rf $XDG_OPT_HOME/nvim-linux64
	tar -C $XDG_OPT_HOME -xzf nvim-linux64.tar.gz
	rm nvim-linux64.tar.gz
fi

# set up python virtual environment for nvim
if [ ! -d "nvim/nvim_pyenv" ]; then
	echo "########## Creating Neovim Virtual Python Environment ##########"
	cd nvim
	python3 -m venv nvim_pyenv
	source nvim_pyenv/bin/activate
	pip install -r requirements.txt
	deactivate
	cd ..
fi

source .bashrc
cd $INSTALL_PATH

echo
echo "########## Installation Complete ##########"
echo "You may need to source .bashrc to get all the new commands."
echo "You may also need to add the generated ssh key to the ssh-agent."
