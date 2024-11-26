# Clear screen
alias c='clear'

# File info
alias ll='ls -l'
alias la='ls -A'

# .tar file
alias untar='tar -zxvf'

# Always resume wget calls
alias wget='wget -c'

# Limit ping to 5 pings
alias ping='ping -c 5'

# Public IP address
alias myip='curl ipinfo.io/ip'

# Fix dual-monitor setup
alias dualmsetup='xrandr --auto && xrandr --output DP-2 --above DP-4'

# Navigate to dotfiles repo
alias dotfiles='cd ~/repos/github.com/travesties/config/'

# Make dir and navigate to dir
mkcd()
{
    mkdir -p -- "$1" && cd -P -- "$1"
}

# Run command in docker service
dcr()
{
    docker compose run $@
}

# Run command in docker service as sudo
sdcr()
{
    sudo docker compose run $@
}

# Start Python web server in current directory
www()
{
    python3 -m http.server "$1"
}
