#!/bin/bash
#
# Theera OS ISO Builder
# Main script to build the Theera OS bootable ISO
#

set -e  # Exit on any error

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"
OUTPUT_DIR="$PROJECT_ROOT/output"
CONFIG_DIR="$PROJECT_ROOT/config"

# OS Configuration
OS_NAME="Theera"
OS_VERSION="1.0"
OS_CODENAME="Aurora"
ISO_NAME="theera-os-${OS_VERSION}.iso"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (use sudo)"
    fi
}

# Check system requirements
check_requirements() {
    log "Checking system requirements..."
    
    # Check available disk space (need at least 20GB)
    AVAILABLE_SPACE=$(df "$PROJECT_ROOT" | awk 'NR==2 {print $4}')
    REQUIRED_SPACE=$((20 * 1024 * 1024))  # 20GB in KB
    
    if [[ $AVAILABLE_SPACE -lt $REQUIRED_SPACE ]]; then
        error "Insufficient disk space. Need at least 20GB free."
    fi
    
    # Check RAM (recommend at least 8GB)
    TOTAL_RAM=$(free -m | awk 'NR==2{print $2}')
    if [[ $TOTAL_RAM -lt 8192 ]]; then
        warn "Low RAM detected. Build may be slow or fail with less than 8GB RAM."
    fi
    
    # Check required packages
    REQUIRED_PACKAGES=(
        "live-build"
        "debootstrap"
        "xorriso"
        "isolinux"
        "syslinux-utils"
        "genisoimage"
        "memtest86+"
        "rsync"
        "wget"
        "curl"
    )
    
    log "Checking required packages..."
    MISSING_PACKAGES=()
    
    for package in "${REQUIRED_PACKAGES[@]}"; do
        if ! dpkg -l | grep -q "^ii.*$package "; then
            MISSING_PACKAGES+=("$package")
        fi
    done
    
    if [[ ${#MISSING_PACKAGES[@]} -gt 0 ]]; then
        log "Installing missing packages: ${MISSING_PACKAGES[*]}"
        apt-get update
        apt-get install -y "${MISSING_PACKAGES[@]}"
    fi
    
    success "System requirements check passed"
}

# Initialize build environment
init_build_env() {
    log "Initializing build environment..."
    
    # Clean previous build
    if [[ -d "$BUILD_DIR" ]]; then
        log "Cleaning previous build directory..."
        rm -rf "$BUILD_DIR"
    fi
    
    # Create build directory
    mkdir -p "$BUILD_DIR"
    mkdir -p "$OUTPUT_DIR"
    
    cd "$BUILD_DIR"
    success "Build environment initialized"
}

# Configure live-build
configure_live_build() {
    log "Configuring live-build..."
    
    # Initialize live-build configuration
    lb config \
        --distribution jammy \
        --derivative-config-directory "$CONFIG_DIR/live-build" \
        --archive-areas "main restricted universe multiverse" \
        --architectures amd64 \
        --binary-images iso-hybrid \
        --bootloaders "grub-efi,grub-pc,syslinux" \
        --chroot-filesystem squashfs \
        --compression gzip \
        --debian-installer live \
        --debian-installer-distribution jammy \
        --debian-installer-gui true \
        --image-name "$OS_NAME" \
        --iso-application "$OS_NAME OS" \
        --iso-preparer "Theera OS Team" \
        --iso-publisher "Theera OS Project" \
        --iso-volume "$OS_NAME $OS_VERSION" \
        --linux-flavours generic \
        --mode ubuntu \
        --security true \
        --updates true \
        --win32-loader false \
        --firmware-chroot true \
        --firmware-binary true
    
    success "Live-build configured"
}

# Setup package lists
setup_package_lists() {
    log "Setting up package lists..."
    
    # Create package list directories
    mkdir -p config/package-lists
    
    # Core system packages
    cat > config/package-lists/core.list.chroot << EOF
# Core system packages
ubuntu-desktop-minimal
linux-generic
linux-headers-generic
linux-firmware
grub-efi-amd64-signed
grub-pc
shim-signed
casper
ubiquity
ubiquity-casper
ubiquity-frontend-gtk
ubiquity-slideshow-ubuntu
ubuntu-advantage-tools

# Network and connectivity
network-manager
network-manager-gnome
wireless-tools
wpasupplicant
openssh-client
curl
wget

# Hardware support
alsa-utils
pulseaudio
bluetooth
bluez
bluez-tools
firmware-linux
firmware-linux-nonfree

# System utilities
systemd
dbus
udev
acpi-support
laptop-detect
hdparm
smartmontools
lm-sensors
EOF

    # Desktop environment packages
    cat > config/package-lists/desktop.list.chroot << EOF
# GNOME Desktop Environment
gnome-shell
gnome-session
gnome-settings-daemon
gnome-control-center
gnome-terminal
nautilus
gnome-software
gnome-tweaks
gnome-extensions-app

# GNOME Applications
gedit
eog
evince
file-roller
gnome-calculator
gnome-calendar
gnome-characters
gnome-clocks
gnome-contacts
gnome-disk-utility
gnome-font-viewer
gnome-logs
gnome-maps
gnome-screenshot
gnome-system-monitor
gnome-weather

# Additional desktop tools
gparted
firefox
thunderbird
libreoffice
rhythmbox
totem
transmission-gtk
cheese
simple-scan
EOF

    # Development tools
    cat > config/package-lists/development.list.chroot << EOF
# Development tools
build-essential
gcc
g++
make
cmake
git
vim
nano
curl
wget
python3
python3-pip
nodejs
npm
ruby
golang-go
rust-all

# Code editors
code
gnome-builder

# Version control
git
subversion
mercurial

# Debugging tools
gdb
strace
ltrace
valgrind
EOF

    # Security packages
    cat > config/package-lists/security.list.chroot << EOF
# Security tools
apparmor
apparmor-profiles
apparmor-utils
ufw
gufw
fail2ban
rkhunter
chkrootkit
clamav
clamav-daemon
unattended-upgrades
apt-listchanges
EOF

    # Multimedia packages
    cat > config/package-lists/multimedia.list.chroot << EOF
# Multimedia codecs and tools
ubuntu-restricted-extras
ffmpeg
vlc
audacity
gimp
inkscape
blender
obs-studio
kdenlive

# Media libraries
gstreamer1.0-plugins-base
gstreamer1.0-plugins-good
gstreamer1.0-plugins-bad
gstreamer1.0-plugins-ugly
gstreamer1.0-libav
EOF

    success "Package lists configured"
}

# Setup custom configuration
setup_custom_config() {
    log "Setting up custom configuration..."
    
    # Copy custom configurations
    if [[ -d "$CONFIG_DIR/chroot" ]]; then
        cp -r "$CONFIG_DIR/chroot"/* config/includes.chroot/ 2>/dev/null || true
    fi
    
    if [[ -d "$CONFIG_DIR/binary" ]]; then
        cp -r "$CONFIG_DIR/binary"/* config/includes.binary/ 2>/dev/null || true
    fi
    
    # Setup hooks
    mkdir -p config/hooks/normal
    
    # Create branding hook
    cat > config/hooks/normal/9999-theera-branding.hook.chroot << 'EOF'
#!/bin/bash
# Theera OS Branding Hook

set -e

echo "Applying Theera OS branding..."

# Set hostname
echo "theera-os" > /etc/hostname

# Update /etc/hosts
cat > /etc/hosts << 'HOSTS_EOF'
127.0.0.1	localhost
127.0.1.1	theera-os

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
HOSTS_EOF

# Set OS release information
cat > /etc/os-release << 'OS_RELEASE_EOF'
NAME="Theera OS"
VERSION="1.0 (Aurora)"
ID=theera
ID_LIKE=ubuntu
PRETTY_NAME="Theera OS 1.0"
VERSION_ID="1.0"
VERSION_CODENAME=aurora
UBUNTU_CODENAME=jammy
HOME_URL="https://theera-os.org/"
SUPPORT_URL="https://theera-os.org/support"
BUG_REPORT_URL="https://theera-os.org/bugs"
PRIVACY_POLICY_URL="https://theera-os.org/privacy"
OS_RELEASE_EOF

# Update LSB release
cat > /etc/lsb-release << 'LSB_RELEASE_EOF'
DISTRIB_ID=Theera
DISTRIB_RELEASE=1.0
DISTRIB_CODENAME=aurora
DISTRIB_DESCRIPTION="Theera OS 1.0"
LSB_RELEASE_EOF

echo "Theera OS branding applied successfully"
EOF

    chmod +x config/hooks/normal/9999-theera-branding.hook.chroot
    
    success "Custom configuration setup complete"
}

# Build the ISO
build_iso() {
    log "Starting ISO build process..."
    
    # Build chroot
    log "Building chroot environment..."
    lb build 2>&1 | tee "$OUTPUT_DIR/build.log"
    
    # Check if build was successful
    if [[ ! -f "live-image-amd64.hybrid.iso" ]]; then
        error "ISO build failed. Check $OUTPUT_DIR/build.log for details."
    fi
    
    # Move ISO to output directory
    mv "live-image-amd64.hybrid.iso" "$OUTPUT_DIR/$ISO_NAME"
    
    # Generate checksums
    cd "$OUTPUT_DIR"
    sha256sum "$ISO_NAME" > "${ISO_NAME}.sha256"
    md5sum "$ISO_NAME" > "${ISO_NAME}.md5"
    
    success "ISO build completed successfully!"
    log "ISO location: $OUTPUT_DIR/$ISO_NAME"
    log "ISO size: $(du -h "$OUTPUT_DIR/$ISO_NAME" | cut -f1)"
}

# Cleanup function
cleanup() {
    log "Cleaning up build environment..."
    cd "$PROJECT_ROOT"
    if [[ -d "$BUILD_DIR" ]]; then
        rm -rf "$BUILD_DIR"
    fi
    success "Cleanup completed"
}

# Main execution
main() {
    log "Starting Theera OS build process..."
    log "OS: $OS_NAME $OS_VERSION ($OS_CODENAME)"
    
    check_root
    check_requirements
    init_build_env
    configure_live_build
    setup_package_lists
    setup_custom_config
    build_iso
    
    success "Theera OS ISO build completed successfully!"
    log "Output: $OUTPUT_DIR/$ISO_NAME"
    
    # Optional cleanup
    read -p "Do you want to clean up build files? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cleanup
    fi
}

# Handle script termination
trap cleanup EXIT

# Execute main function
main "$@"
