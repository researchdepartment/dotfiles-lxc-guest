#!/bin/bash
if [ "$(id -u)" != "0" ]; then
    SUDO="sudo"
else
    SUDO=""
fi

if command -v yum >/dev/null; then
    $SUDO yum -y install fish yum-cron nano
    #$SUDO sed -i 's|^update_cmd = default|update_cmd = security|' /etc/yum/yum-cron.conf
    $SUDO sed -i 's|^download_updates = no|download_updates = yes|' /etc/yum/yum-cron.conf
    $SUDO sed -i 's|^apply_updates = no|apply_updates = yes|' /etc/yum/yum-cron.conf
    $SUDO systemctl enable yum-cron.service
    $SUDO systemctl start yum-cron.service
fi

if command -v dnf >/dev/null; then
    $SUDO dnf -y install fish nano dnf-automatic
    #$SUDO sed -i 's|^upgrade_type = default|upgrade_type = security|' /etc/dnf/automatic.conf
    $SUDO sed -i 's|^download_updates = no|download_updates = yes|' /etc/dnf/automatic.conf
    $SUDO sed -i 's|^apply_updates = no|apply_updates = yes|' /etc/dnf/automatic.conf
    $SUDO systemctl enable --now dnf-automatic.timer
fi

if command -v apt >/dev/null; then
    $SUDO apt -y install fish nano
    $SUDO apt -y install unattended-upgrades
    $SUDO dpkg-reconfigure -f noninteractive unattended-upgrades
    $SUDO echo 'APT::Periodic::AutocleanInterval "7";' >> /etc/apt/apt.conf.d/20auto-upgrades
    $SUDO systemctl enable unattended-upgrades
    $SUDO systemctl start unattended-upgrades
fi

if command -v apk >/dev/null; then
    $SUDO apk add fish nano
    $SUDO apk add crond && \
    $SUDO rc-service crond start && \
    $SUDO rc-update add crond
    $SUDO echo -e "#!/bin/sh\napk upgrade --update | sed \"s/^/[\`date\`] /\" >> /dev/null" > /etc/periodic/daily/apk-autoupgrade && \
    $SUDO chmod 700 /etc/periodic/daily/apk-autoupgrade
fi

if command -v pacman >/dev/null; then
    $SUDO pacman -S fish nano --noconfirm
    #$SUDO echo -e "#!/bin/sh\npacman -Syy && pacman -Su --noconfirm" > /etc/cron.daily/pacman-autoupgrade && \
    #$SUDO chmod 700 /etc/cron.daily/pacman-autoupgrade
fi

FISH_PATH=$(cat /etc/shells | grep fish | head -n1)
FISH_PATH_ESC=$(cat /etc/shells | grep fish | head -n1 | sed 's/\//\\\//g')
FISH_CONFIG="/etc/fish/config.fish"
mkdir -p "/etc/fish/"
                                                  
curl -LJo $FISH_CONFIG https://github.com/researcx/dotfiles-install-shell-fish/raw/main/config.fish

$SUDO sed -i "s/\/bin\/ash/$FISH_PATH_ESC/g" /etc/passwd
$SUDO sed -i "s/\/bin\/bash/$FISH_PATH_ESC/g" /etc/passwd
$SUDO sed -i "s/\/bin\/zsh/$FISH_PATH_ESC/g" /etc/passwd

su $USER
