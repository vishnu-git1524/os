# Theera OS Configuration Guide

This guide covers the configuration of Theera OS for various use cases and environments.

## Desktop Configuration

### GNOME Settings

#### Default Settings
Theera OS uses dconf to set system-wide defaults:
- **Theme**: Adwaita-dark with custom Theera colors
- **Icons**: Adwaita icon theme with Theera customizations
- **Fonts**: Ubuntu font family
- **Extensions**: Dash-to-Dock, AppIndicator Support

#### Customizing Defaults
Edit `/etc/dconf/db/local.d/00-theera-defaults`:
```ini
[org/gnome/desktop/interface]
gtk-theme='Adwaita-dark'
icon-theme='Adwaita'
font-name='Ubuntu 11'

[org/gnome/shell]
favorite-apps=['org.gnome.Nautilus.desktop', 'firefox.desktop', 'org.gnome.Terminal.desktop']
```

Apply changes:
```bash
sudo dconf update
```

#### Locking Settings
Prevent users from changing certain settings by editing `/etc/dconf/db/local.d/locks/00-theera-locks`:
```ini
[org/gnome/desktop/privacy]
report-technical-problems
send-software-usage-stats
```

### User Environment

#### Shell Configuration
Default shell settings in `/etc/skel/.bashrc`:
```bash
# Theera OS shell customizations
export EDITOR=nano
export BROWSER=firefox
export TERM=gnome-terminal

# Custom aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Development environment
export PATH="$HOME/.local/bin:$PATH"
```

#### Desktop Files
Custom applications in `/usr/share/applications/`:
- Theera Welcome application
- System configuration tools
- Hardware setup utilities

## Network Configuration

### NetworkManager
Default configuration in `/etc/NetworkManager/conf.d/theera-defaults.conf`:
```ini
[main]
dns=systemd-resolved
no-auto-default=*

[connectivity]
uri=http://connectivity-check.theera-os.org/

[device]
wifi.scan-rand-mac-address=yes
ethernet.cloned-mac-address=preserve
```

### VPN Support
Pre-configured VPN protocols:
- OpenVPN
- WireGuard
- IKEv2/IPSec
- PPTP (legacy)

### Firewall Configuration
UFW (Uncomplicated Firewall) default rules:
```bash
# Default policies
ufw --force enable
ufw default deny incoming
ufw default allow outgoing

# Allow essential services
ufw allow out 53    # DNS
ufw allow out 80    # HTTP
ufw allow out 443   # HTTPS
ufw allow out 123   # NTP
```

## Security Configuration

### AppArmor
Application confinement profiles in `/etc/apparmor.d/`:

#### Firefox Profile
Restricts Firefox access to system resources:
```bash
# Enable Firefox profile
sudo aa-enforce /etc/apparmor.d/firefox
```

#### Custom Profiles
Create profiles for additional applications:
```bash
sudo aa-genprof application-name
```

### Automatic Updates
Configure unattended upgrades in `/etc/apt/apt.conf.d/50unattended-upgrades`:
```conf
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "Theera:${distro_codename}-security";
};

Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Automatic-Reboot "false";
```

### User Access Control
Sudo configuration for administrative tasks:
```bash
# Add user to sudo group
sudo usermod -aG sudo username

# Configure sudo timeout
echo "Defaults timestamp_timeout=15" | sudo tee /etc/sudoers.d/timeout
```

## Hardware Configuration

### Graphics Drivers

#### NVIDIA
Automatic driver installation:
```bash
sudo ubuntu-drivers autoinstall
```

Manual installation:
```bash
sudo apt install nvidia-driver-470
sudo reboot
```

#### AMD
Open source drivers are included by default. For additional features:
```bash
sudo apt install mesa-vulkan-drivers
sudo apt install libvulkan1
```

#### Intel
Integrated graphics drivers:
```bash
sudo apt install intel-media-va-driver
sudo apt install i965-va-driver
```

### Audio Configuration

#### PulseAudio
Default audio server with automatic device detection:
```bash
# Restart audio system
pulseaudio -k
pulseaudio --start
```

#### PipeWire (Optional)
For low-latency audio:
```bash
sudo apt install pipewire pipewire-pulse
systemctl --user enable pipewire
systemctl --user start pipewire
```

### Power Management
Laptop-optimized settings:
```bash
# Install TLP for advanced power management
sudo apt install tlp tlp-rdw
sudo systemctl enable tlp
sudo systemctl start tlp

# Configure power profiles
sudo apt install power-profiles-daemon
```

### Bluetooth
Automatic pairing and management:
```bash
# Enable Bluetooth service
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

# Auto-connect known devices
echo "AutoConnect=true" | sudo tee -a /etc/bluetooth/main.conf
```

## Development Environment

### Programming Languages

#### Python
Python 3 with pip and development tools:
```bash
# Install additional Python tools
sudo apt install python3-dev python3-venv python3-pip
pip3 install --user pipenv virtualenv

# Configure Python environment
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

#### Node.js
LTS version with npm:
```bash
# Install via NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install nodejs

# Global packages location
npm config set prefix '~/.npm-global'
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
```

#### Git Configuration
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
git config --global pull.rebase false
```

### IDEs and Editors

#### VS Code
Pre-installed with useful extensions:
- Python
- GitLens
- Bracket Pair Colorizer
- Material Icon Theme

#### GNOME Builder
Native GNOME IDE with support for:
- C/C++
- Python
- JavaScript
- Rust
- Go

### Docker Support
Container development platform:
```bash
# Install Docker
sudo apt install docker.io docker-compose
sudo usermod -aG docker $USER

# Enable Docker service
sudo systemctl enable docker
sudo systemctl start docker
```

## Package Management

### APT Configuration
Main package manager configuration:
```bash
# Add additional repositories
sudo add-apt-repository ppa:example/ppa
sudo apt update

# Hold specific packages
sudo apt-mark hold package-name

# Install .deb files
sudo dpkg -i package.deb
sudo apt install -f  # Fix dependencies
```

### Snap Package Manager
Universal packages:
```bash
# List installed snaps
snap list

# Install snap packages
sudo snap install package-name

# Update all snaps
sudo snap refresh
```

### Flatpak Support
Sandboxed applications:
```bash
# Add Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install applications
flatpak install flathub org.gimp.GIMP

# Update Flatpak applications
flatpak update
```

## System Monitoring

### Performance Monitoring
Built-in tools for system monitoring:
- GNOME System Monitor
- htop (command line)
- iotop (I/O monitoring)
- nethogs (network monitoring)

### Log Management
```bash
# View system logs
sudo journalctl -f

# View specific service logs
sudo journalctl -u service-name

# View boot logs
sudo journalctl -b
```

### System Health
```bash
# Check disk usage
df -h
du -sh /home/*

# Check memory usage
free -h

# Check system temperature
sensors

# Check disk health
sudo smartctl -a /dev/sda
```

## Backup and Recovery

### System Backup
```bash
# Create system snapshot with Timeshift
sudo apt install timeshift
sudo timeshift --create --comments "Before system update"

# Backup user data with rsync
rsync -av --exclude='.cache' /home/user/ /backup/location/
```

### Recovery Options
- GRUB rescue mode
- Live USB recovery
- System restore from Timeshift snapshots

## Accessibility

### Screen Reader
Orca screen reader configuration:
```bash
# Enable Orca
gsettings set org.gnome.desktop.a11y.applications screen-reader-enabled true

# Configure speech settings
orca --setup
```

### Visual Accessibility
High contrast and magnification:
```bash
# Enable high contrast theme
gsettings set org.gnome.desktop.interface gtk-theme 'HighContrast'

# Enable magnifier
gsettings set org.gnome.desktop.a11y.magnifier mag-factor 2.0
```

### Motor Accessibility
On-screen keyboard and mouse alternatives:
```bash
# Enable on-screen keyboard
gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled true
```

## Localization

### Language Support
Installing additional languages:
```bash
# Install language packs
sudo apt install language-pack-es language-pack-fr

# Configure locale
sudo dpkg-reconfigure locales
```

### Input Methods
Multi-language input support:
```bash
# Install IBus input framework
sudo apt install ibus ibus-gtk ibus-gtk3

# Configure input methods
ibus-setup
```

### Regional Settings
Date, time, and number formats:
```bash
# Set timezone
sudo timedatectl set-timezone America/New_York

# Configure regional formats
sudo localectl set-locale LANG=en_US.UTF-8
```

## Troubleshooting

### Common Issues

#### Boot Problems
```bash
# Repair GRUB bootloader
sudo grub-install /dev/sda
sudo update-grub
```

#### Network Issues
```bash
# Restart NetworkManager
sudo systemctl restart NetworkManager

# Reset network configuration
sudo rm /etc/NetworkManager/system-connections/*
```

#### Audio Problems
```bash
# Reinstall audio drivers
sudo apt install --reinstall alsa-base pulseaudio

# Reset PulseAudio
pulseaudio -k
pulseaudio --start
```

#### Graphics Issues
```bash
# Reset graphics drivers
sudo apt purge nvidia-*
sudo ubuntu-drivers autoinstall
sudo reboot
```

### System Recovery
Boot from live USB and:
```bash
# Mount system partition
sudo mount /dev/sda1 /mnt

# Chroot into system
sudo chroot /mnt

# Repair system
apt update && apt upgrade
```
