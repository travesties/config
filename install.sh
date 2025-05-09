#!/usr/bin/env bash
INSTALL_PATH=$PWD

echo
echo "Let's setup your environment!"

sudo apt -y update && sudo apt -y upgrade
sudo apt -y install ssh git vim curl

read -p "Enter your GitHub username: " ghuser
read -p "Enter your GitHub email: " ghemail

git config --global user.name "$ghuser"
git config --global user.email "$ghemail"
git config --global init.defaultBranch main

mkdir -p $HOME/.ssh && touch $HOME/.ssh/known_hosts

# Only keyscan github.com if it hasn't already been done
if [ ! -s $HOME/.ssh/known_hosts ]; then
	ssh-keyscan github.com >>$HOME/.ssh/known_hosts
fi

# Create ssh key if none exist
if [ ! -s $HOME/.ssh/id_ed25519 ]; then
	ssh-keygen -t ed25519 -C $ghemail
fi

[ -n "$SSH_AUTH_SOCK" ] || eval "$(ssh-agent)"
ssh-add $HOME/.ssh/id_ed25519

echo
cat $HOME/.ssh/id_ed25519.pub
while true; do
	echo "Have you added the public key to your GitHub account? (y/n) "
	read -n 1 key
	if [ $key == "y" ] || [ $key == "Y" ]; then
		break
	elif [ $key == "n" ] || [ $key == "N" ]; then
		echo "You must add the public key to continue."
	fi
done

# Create github.com repository structure and clone all necessary repos
if [ ! -d $HOME/repos/github.com/$ghuser ]; then
	mkdir -p $HOME/repos/github.com/$ghuser

	# dotfiles config repo
	git clone git@github.com:$ghuser/config.git $HOME/repos/github.com/$ghuser/config
	# obsidian vaults
	git clone git@github.com:$ghuser/obsidian.git $HOME/repos/github.com/$ghuser/obsidian
fi

cd $HOME/repos/github.com/$ghuser/config

# Link bash files to home
ln -sTf "$PWD/.bashrc" "$HOME/.bashrc"
ln -sTf "$PWD/.bash_aliases" "$HOME/.bash_aliases"

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
mkdir -p "$BASH_COMPLETIONS_DIR"

# Install all necessary packages for workflow setup
sudo apt -y install man-db xclip python3 python3-pip python3-venv make unzip ripgrep fontconfig rlwrap xsel

# Install custom scripts
chmod +x $PWD/scripts/
ln -sf $PWD/scripts/* $XDG_BIN_HOME/

# rust and cargo
if ! command -v rustup &>/dev/null; then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	source $HOME/.bashrc
else
	rustup override set stable
	rustup update stable
fi

### GO
if [ ! -d "$GOINSTALL" ]; then
	echo
	echo "########## Installing Golang ##########"
	curl -LO https://go.dev/dl/go1.22.1.linux-amd64.tar.gz
	tar -C "$HOME/.local" -xzf go1.22.1.linux-amd64.tar.gz
	rm -f go1.22.1.linux-amd64.tar.gz

	go install github.com/go-delve/delve/cmd/dlv@latest
fi

### Flatpak
if ! command -v flatpak &>/dev/null; then
	echo
	echo "########## Installing Flatpak ##########"
	sudo apt install -y flatpak
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

if ! $(flatpak list --columns=name | grep 'GNU Image Manipulation Program'); then
	echo
	echo "===> Installing GIMP flatpak..."
	flatpak install -y https://flathub.org/repo/appstream/org.gimp.GIMP.flatpakref
fi

### i3 window manager
if ! command -v i3 &>/dev/null; then
	echo
	echo "########## i3 ##########"
	sudo apt -y install i3 nitrogen picom rofi pulseaudio xautolock
	ln -sTf "$PWD/i3" "$XDG_CONFIG_HOME/i3"
	ln -sTf "$PWD/picom" "$XDG_CONFIG_HOME/picom"
	ln -sTf "$PWD/nitrogen" "$XDG_CONFIG_HOME/nitrogen"
	ln -sTf "$PWD/rofi" "$XDG_CONFIG_HOME/rofi"

	chmod +x $PWD/i3/scripts/*

	cp -r $PWD/wallpapers/* $HOME/Pictures/Wallpapers/
fi

### NODE
if [ ! -d "$XDG_CONFIG_HOME/nvm" ]; then
	echo
	echo "########## Installing Node.js and NVM ##########"
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
	source .bashrc
	nvm install --lts
fi

### Docker
if ! command -v docker &>/dev/null; then
	echo
	echo "########## Docker Engine ##########"
	for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove -y $pkg; done

	echo
	echo "Setting up Docker APT repository..."
	# Add Docker's official GPG key:
	sudo apt-get -y update
	sudo apt-get -y install ca-certificates curl
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc

	# Add the repository to Apt sources:
	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
	  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
		sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
	sudo apt-get -y update

	echo
	echo "Installing latest version..."
	sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

	echo
	echo "Verifying successful installation..."
	sudo docker run hello-world
fi

### Bat (https://github.com/sharkdp/bat)
sudo apt -y install bat

# Due to name conflict, bat may be installed as batcat.
# If this happens, create a bat symlink
if command -v batcat &>/dev/null; then
	ln -sf /usr/bin/batcat $XDG_BIN_HOME/bat
fi

### Tmux
sudo apt -y install tmux libnotify-bin
ln -sTf "$PWD/tmux" "$XDG_CONFIG_HOME/tmux"

# Install tmp (tmux plugin manager)
# tmux/plugins dir is in the gitignore list
if [ ! -d "$XDG_CONFIG_HOME/tmux/plugins/tpm" ]; then
	git clone https://github.com/tmux-plugins/tpm $XDG_CONFIG_HOME/tmux/plugins/tpm

	# Install tpm plugins by starting a detached server and running the install script
	tmux start-server &&
		tmux new-session -d &&
		sleep 1 &&
		$XDG_CONFIG_HOME/tmux/plugins/tpm/scripts/install_plugins.sh &&
		tmux kill-server
fi

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

### cheat.sh
if [ ! -f $XDG_BIN_HOME/cht.sh ]; then
	echo
	echo "########## Installing cheat.sh ##########"
	curl -s https://cht.sh/:cht.sh | tee $XDG_BIN_HOME/cht.sh && chmod +x $XDG_BIN_HOME/cht.sh
fi

### lazygit
if [ ! -f $XDG_BIN_HOME/lazygit ]; then
	echo
	echo "########## Installing Lazygit ##########"
	LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
	curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
	tar xf lazygit.tar.gz lazygit
	install lazygit $XDG_BIN_HOME
	rm lazygit lazygit.tar.gz
fi

### NEOVIM
ln -sTf "$PWD/nvim" "$XDG_CONFIG_HOME/nvim"

if [ ! -d "$XDG_OPT_HOME/nvim-linux64" ]; then
	echo
	echo "########## Installing Neovim ##########"
	curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
	rm -rf $XDG_OPT_HOME/nvim-linux-x86_64
	tar -C $XDG_OPT_HOME -xzf nvim-linux-x86_64.tar.gz
	rm nvim-linux-x86_64.tar.gz
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

# install marksman markdown lsp
if [ ! command -v marksman ] &>/dev/null; then
	curl -o marksman https://github.com/artempyanykh/marksman/releases/download/latest/marksman-linux-arm64
	chmod +x marksman
	mv marksman $XDG_BIN_HOME/marksman
fi

# install taplo TOML lsp
if [ ! command -v taplo ] &>/dev/null; then
	cargo install --features lsp --locked taplo-cli
fi

### Obsidian
if [ ! command -v obsidian ] &>/dev/null; then
	echo
	echo "########## Installing Obsidian ##########"
	curl -LO obsidian https://github.com/obsidianmd/obsidian-releases/releases/download/v1.6.3/Obsidian-1.6.3-arm64.AppImage
	chmod +x obsidian
	mv obsidian $XDG_BIN_HOME/obsidian
fi

### Alacritty
ln -sTf "$PWD/alacritty" "$XDG_CONFIG_HOME/alacritty"

if [ ! -d "$REPOS/github.com/alacritty" ]; then
	mkdir -p $REPOS/github.com/alacritty
	cd $REPOS/github.com/alacritty

	# install dependencies
	sudo apt -y install gzip scdoc cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3

	# download Alacritty source
	git clone https://github.com/alacritty/alacritty.git
	cd alacritty

	# build release
	cargo build --release

	# Create desktop entry (NOTE: you will need to log out and log in to find the start up menu option)
	cp target/release/alacritty $XDG_BIN_HOME
	sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
	sudo desktop-file-install extra/linux/Alacritty.desktop
	sudo update-desktop-database

	# install man pages
	mkdir -p $XDG_DATA_HOME/man/man1
	mkdir -p $XDG_DATA_HOME/man/man5

	scdoc <extra/man/alacritty.1.scd | gzip -c | sudo tee $XDG_DATA_HOME/man/man1/alacritty.1.gz >/dev/null
	scdoc <extra/man/alacritty-msg.1.scd | gzip -c | sudo tee $XDG_DATA_HOME/man/man1/alacritty-msg.1.gz >/dev/null
	scdoc <extra/man/alacritty.5.scd | gzip -c | sudo tee $XDG_DATA_HOME/man/man5/alacritty.5.gz >/dev/null
	scdoc <extra/man/alacritty-bindings.5.scd | gzip -c | sudo tee $XDG_DATA_HOME/man/man5/alacritty-bindings.5.gz >/dev/null

	# install bash completions
	cp extra/completions/alacritty.bash $BASH_COMPLETIONS_DIR/alacritty
fi

### Brave browser
if [ ! command -v brave-browser ] &>/dev/null; then
	echo
	echo "########## Installing Brave Browser ##########"

	sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

	echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

	sudo apt -y update

	sudo apt -y install brave-browser
fi

source .bashrc
cd $INSTALL_PATH

echo
echo "########## Installation Complete ##########"
echo "You may need to source .bashrc to get all the new commands."
echo "You may need to add the generated ssh key to the ssh-agent."
echo "You may need to logout and login to see Alacritty in the start menu."
