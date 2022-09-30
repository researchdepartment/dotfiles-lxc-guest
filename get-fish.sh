 #!/bin/bash
if [ "$EUID" -ne 0 ] ; then
    FISH_CONFIG="$HOME/.config/fish/config.fish"
    mkdir -p "$HOME/.config/fish/"
    SUDO="sudo"
else
    FISH_CONFIG="/etc/fish/config.fish"
    mkdir -p "/etc/fish/"
    SUDO=""
fi

if command -v yum >/dev/null; then
    $SUDO yum -y install fish curl
fi

if command -v dnf >/dev/null; then
    $SUDO dnf -y install fish curl
fi

if command -v apt >/dev/null; then
    $SUDO apt -y install fish curl
fi

if command -v apk >/dev/null; then
    $SUDO apk add fish curl
fi

if command -v pacman >/dev/null; then
    $SUDO pacman -S fish curl --noconfirm
fi

FISH_PATH=$(cat /etc/shells | grep fish | head -n1)                                                    
curl -LJo $FISH_CONFIG https://github.com/researcx/dotfiles-install-shell-fish/raw/main/config.fish
usermod --shell $FISH_PATH $USER
$FISH_PATH
