#!/bin/bash
#
# Theera OS Post-Installation Configuration Script
# Configures the system after installation is complete
#

set -e

# Configuration variables
OS_NAME="Theera OS"
OS_VERSION="1.0"
USER_NAME="${1:-theera}"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1"
}

error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" >&2
    exit 1
}

# Configure GNOME desktop environment
configure_gnome() {
    log "Configuring GNOME desktop environment..."
    
    # Enable required extensions
    sudo -u "$USER_NAME" gnome-extensions enable dash-to-dock@micxgx.gmail.com
    sudo -u "$USER_NAME" gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
    
    # Set favorite applications
    sudo -u "$USER_NAME" gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'firefox.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Software.desktop', 'libreoffice-writer.desktop', 'org.gnome.Settings.desktop']"
    
    # Configure interface settings
    sudo -u "$USER_NAME" gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
    sudo -u "$USER_NAME" gsettings set org.gnome.desktop.interface show-battery-percentage true
    sudo -u "$USER_NAME" gsettings set org.gnome.desktop.interface clock-show-weekday true
    
    # Configure privacy settings
    sudo -u "$USER_NAME" gsettings set org.gnome.desktop.privacy report-technical-problems false
    sudo -u "$USER_NAME" gsettings set org.gnome.desktop.privacy send-software-usage-stats false
    
    # Configure power settings
    sudo -u "$USER_NAME" gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
    sudo -u "$USER_NAME" gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 1800
    
    log "GNOME configuration completed"
}

# Configure security settings
configure_security() {
    log "Configuring security settings..."
    
    # Enable AppArmor
    systemctl enable apparmor
    systemctl start apparmor
    
    # Load AppArmor profiles
    aa-enforce /etc/apparmor.d/*
    
    # Configure UFW firewall
    ufw --force enable
    ufw default deny incoming
    ufw default allow outgoing
    
    # Allow essential services
    ufw allow out 53/udp    # DNS
    ufw allow out 80/tcp    # HTTP
    ufw allow out 443/tcp   # HTTPS
    ufw allow out 123/udp   # NTP
    
    # Enable automatic security updates
    systemctl enable unattended-upgrades
    systemctl start unattended-upgrades
    
    # Enable daily security update timer
    systemctl enable theera-security-updates.timer
    systemctl start theera-security-updates.timer
    
    log "Security configuration completed"
}

# Configure network settings
configure_network() {
    log "Configuring network settings..."
    
    # Enable NetworkManager
    systemctl enable NetworkManager
    systemctl start NetworkManager
    
    # Configure systemd-resolved
    systemctl enable systemd-resolved
    systemctl start systemd-resolved
    
    # Enable Avahi for local network discovery
    systemctl enable avahi-daemon
    systemctl start avahi-daemon
    
    log "Network configuration completed"
}

# Configure hardware support
configure_hardware() {
    log "Configuring hardware support..."
    
    # Enable Bluetooth
    systemctl enable bluetooth
    systemctl start bluetooth
    
    # Configure audio
    systemctl --user enable pulseaudio
    systemctl --user start pulseaudio
    
    # Enable CUPS printing
    systemctl enable cups
    systemctl start cups
    
    # Configure power management
    systemctl enable tlp
    systemctl start tlp
    
    log "Hardware configuration completed"
}

# Configure development environment
configure_development() {
    log "Configuring development environment..."
    
    # Configure Git global settings
    sudo -u "$USER_NAME" git config --global init.defaultBranch main
    sudo -u "$USER_NAME" git config --global pull.rebase false
    
    # Create development directories
    sudo -u "$USER_NAME" mkdir -p "/home/$USER_NAME/Development"
    sudo -u "$USER_NAME" mkdir -p "/home/$USER_NAME/.local/bin"
    
    # Configure Python environment
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "/home/$USER_NAME/.bashrc"
    
    # Configure Node.js global packages
    sudo -u "$USER_NAME" npm config set prefix "/home/$USER_NAME/.npm-global"
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "/home/$USER_NAME/.bashrc"
    
    log "Development environment configuration completed"
}

# Configure system services
configure_services() {
    log "Configuring system services..."
    
    # Enable essential services
    systemctl enable gdm3
    systemctl enable NetworkManager
    systemctl enable bluetooth
    systemctl enable cups
    systemctl enable avahi-daemon
    
    # Configure Plymouth boot splash
    update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/theera/theera.plymouth 100
    update-alternatives --set default.plymouth /usr/share/plymouth/themes/theera/theera.plymouth
    update-initramfs -u
    
    log "System services configuration completed"
}

# Update system and packages
update_system() {
    log "Updating system packages..."
    
    apt update
    apt upgrade -y
    apt autoremove -y
    apt autoclean
    
    # Update font cache
    fc-cache -f -v
    
    # Update desktop database
    update-desktop-database
    
    # Update MIME database
    update-mime-database /usr/share/mime
    
    log "System update completed"
}

# Main configuration function
main() {
    log "Starting Theera OS post-installation configuration..."
    log "Configuring for user: $USER_NAME"
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
    fi
    
    # Check if user exists
    if ! id "$USER_NAME" &>/dev/null; then
        error "User $USER_NAME does not exist"
    fi
    
    # Run configuration steps
    configure_gnome
    configure_security
    configure_network
    configure_hardware
    configure_development
    configure_services
    update_system
    
    log "Theera OS configuration completed successfully!"
    log "Please reboot the system to apply all changes."
}

# Execute main function
main "$@"
