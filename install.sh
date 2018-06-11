#!/bin/bash

if [ $# -eq 2 ]
  then
    echo "Not enough arguments supplied. This script takes in the username as first argument and the chrome page to show as the second argument"
    exit 1
fi


# Installs the openssh Server
dnf install openssh-server -y

# Install the Fedore Workstation Repo's which include the Google-Chome-Stable repo
dnf install fedora-workstation-repositories -y

# Enabled the Chrome Repo
dnf config-manager --set-enabled google-chrome

# Installs Chrome
dnf install google-chrome-stable -y

# Enabled the OpenSSH Server in startup
systemctl enable sshd

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

# Setups autologin
printf "# GDM configuration storage\r\n\r\n[daemon]\r\n# Uncoment the line below to force the login screen to use Xorg\r\n#WaylandEnable=false\r\n\r\nAutomaticLoginEnable=True\r\nAutomaticLogin=$1\r\n\r\n[security]\r\n\r\n[xdmcp]\r\n\r\n[chooser]\r\n\r\n[debug]\r\n# Uncomment the line below to turn on debugging\r\n#Enable=true\r\n" > /etc/gdm/custom.conf

# Disables the Gnome Keyring
mv /usr/bin/gnome-keyring-daemon /usr/bin/gnome-keyring-daemon.bak

# Setup Crontab
printf "#!/bin/bash\nsudo reboot" > /home/$1/crontab.sh

chmod +x /home/$1/crontab.sh

printf "0 4 * * * /home/$1/crontab.sh > /var/log/restart.log 2>&1" > /var/spool/cron/root
