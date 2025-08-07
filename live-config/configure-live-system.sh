#!/bin/bash
#
# Theera OS Live System Configuration
# Sets up the live environment for testing and installation
#

set -e

# Configure live user
LIVE_USER="theera"
LIVE_USER_FULLNAME="Theera Live User"

# Create live user
if ! id "$LIVE_USER" &>/dev/null; then
    useradd -m -s /bin/bash -G sudo,adm,audio,video,plugdev,netdev,bluetooth "$LIVE_USER"
    echo "$LIVE_USER:$LIVE_USER" | chpasswd
    echo "$LIVE_USER ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$LIVE_USER"
fi

# Set up user directories
sudo -u "$LIVE_USER" xdg-user-dirs-update

# Configure automatic login for live session
mkdir -p /etc/gdm3
cat > /etc/gdm3/custom.conf << EOF
[daemon]
AutomaticLoginEnable=true
AutomaticLogin=$LIVE_USER
WaylandEnable=false

[security]

[xdmcp]

[chooser]

[debug]
EOF

# Configure desktop environment
sudo -u "$LIVE_USER" dbus-launch gsettings set org.gnome.desktop.session idle-delay 0
sudo -u "$LIVE_USER" dbus-launch gsettings set org.gnome.desktop.screensaver lock-enabled false
sudo -u "$LIVE_USER" dbus-launch gsettings set org.gnome.desktop.lockdown disable-lock-screen true

# Configure live system desktop
cat > "/home/$LIVE_USER/Desktop/Install Theera OS.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Install Theera OS
Comment=Install Theera OS to your computer
GenericName=OS Installer
Exec=ubiquity --desktop
Icon=ubiquity
Terminal=false
StartupNotify=true
Categories=System;
Keywords=installer;calamares;install;
EOF

chmod +x "/home/$LIVE_USER/Desktop/Install Theera OS.desktop"
chown "$LIVE_USER:$LIVE_USER" "/home/$LIVE_USER/Desktop/Install Theera OS.desktop"

# Add live system applications to desktop
sudo -u "$LIVE_USER" cp /usr/share/applications/firefox.desktop "/home/$LIVE_USER/Desktop/"
sudo -u "$LIVE_USER" cp /usr/share/applications/org.gnome.Nautilus.desktop "/home/$LIVE_USER/Desktop/"
sudo -u "$LIVE_USER" cp /usr/share/applications/gparted.desktop "/home/$LIVE_USER/Desktop/"

# Trust desktop files
sudo -u "$LIVE_USER" gio set "/home/$LIVE_USER/Desktop/Install Theera OS.desktop" metadata::trusted true
sudo -u "$LIVE_USER" gio set "/home/$LIVE_USER/Desktop/firefox.desktop" metadata::trusted true
sudo -u "$LIVE_USER" gio set "/home/$LIVE_USER/Desktop/org.gnome.Nautilus.desktop" metadata::trusted true
sudo -u "$LIVE_USER" gio set "/home/$LIVE_USER/Desktop/gparted.desktop" metadata::trusted true

# Configure live system services
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups
systemctl enable avahi-daemon
systemctl enable gdm3

# Disable unnecessary services in live environment
systemctl disable unattended-upgrades
systemctl disable apt-daily
systemctl disable apt-daily-upgrade

# Configure live system network
cat > /etc/NetworkManager/conf.d/live-system.conf << EOF
[main]
# Don't wait for network on boot in live system
no-auto-default=*

[device]
# Allow all devices to be managed
wifi.scan-rand-mac-address=no
EOF

echo "Live system configuration completed successfully!"
