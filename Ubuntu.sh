#!/bin/bash

if [ $# -eq 2 ]
  then
    echo "Not enough arguments supplied. This script takes in the username as first argument and the chrome page to show as the second argument"
    exit 1
fi

wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list

apt-get update && apt-get install \
  openssh-server -y \
  google-chrome-stable

# Enabled the OpenSSH Server in startup
systemctl enable ssh.service

# Starts the SSH Server
systemctl start sshd

# Creates the Chrome script which is used for Starting chrome and the appointed webpage
touch /home/$1/chrome.sh

# Makes the script ours
chown $1:$1 /home/$1/chrome.sh

# Makes the script executeable
chmod +x /home/$1/chrome.sh

# Puts the Chrome command in the script
printf "#!/bin/bash\ngoogle-chrome-stable --kiosk --incognito --force-device-scale-factor=1.2 $2" > /home/$1/chrome.sh

# Creates the Autostart directory
mkdir -p /home/$1/.config/autostart

# Creates the autostart script  
touch /home/$1/.config/autostart/resfix.desktop

# Writes the Autostart script
printf "[Desktop Entry]\nName=Resolution Fix\nExec=/home/$1/chrome.sh\nTerminal=true\nType=Application" > /home/$1/.config/autostart/resfix.desktop

# Disables the Gnome Keyring
#mv /usr/bin/gnome-keyring-daemon /usr/bin/gnome-keyring-daemon.bak

# Setup Crontab
# printf "#!/bin/bash\nsudo reboot" > /home/$1/crontab.sh

# chmod +x /home/$1/crontab.sh

# printf "0 4 * * * /home/$1/crontab.sh > /var/log/restart.log 2>&1" > /var/spool/cron/root
