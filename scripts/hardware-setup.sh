#!/bin/bash
#
# Theera OS Hardware Detection and Driver Installation
# Automatically detects and installs appropriate drivers
#

set -e

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1"
}

warn() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] $1"
}

error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" >&2
}

# Detect and configure graphics drivers
configure_graphics() {
    log "Detecting graphics hardware..."
    
    # Detect NVIDIA graphics
    if lspci | grep -i nvidia > /dev/null; then
        log "NVIDIA graphics detected"
        
        # Check if proprietary drivers are needed
        if ubuntu-drivers devices | grep nvidia > /dev/null; then
            log "Installing NVIDIA proprietary drivers..."
            ubuntu-drivers autoinstall
            
            # Configure NVIDIA settings
            cat > /etc/X11/xorg.conf.d/20-nvidia.conf << EOF
Section "Device"
    Identifier "NVIDIA Card"
    Driver "nvidia"
    VendorName "NVIDIA Corporation"
    Option "NoLogo" "true"
    Option "UseEDID" "false"
    Option "ConnectedMonitor" "DFP"
EndSection
EOF
        fi
    fi
    
    # Detect AMD graphics
    if lspci | grep -i amd | grep -i vga > /dev/null; then
        log "AMD graphics detected"
        
        # Install AMD drivers
        apt install -y mesa-vulkan-drivers xserver-xorg-video-amdgpu
        
        # Configure AMD settings
        cat > /etc/X11/xorg.conf.d/20-amdgpu.conf << EOF
Section "Device"
    Identifier "AMD"
    Driver "amdgpu"
    Option "TearFree" "true"
    Option "DRI" "3"
EndSection
EOF
    fi
    
    # Detect Intel graphics
    if lspci | grep -i intel | grep -i vga > /dev/null; then
        log "Intel graphics detected"
        
        # Install Intel drivers
        apt install -y intel-media-va-driver i965-va-driver
        
        # Configure Intel settings
        cat > /etc/X11/xorg.conf.d/20-intel.conf << EOF
Section "Device"
    Identifier "Intel Graphics"
    Driver "intel"
    Option "AccelMethod" "sna"
    Option "TearFree" "true"
EndSection
EOF
    fi
}

# Configure Wi-Fi drivers
configure_wifi() {
    log "Configuring Wi-Fi drivers..."
    
    # Detect Wi-Fi hardware
    WIFI_DEVICES=$(lspci | grep -i wireless || true)
    
    if [[ -n "$WIFI_DEVICES" ]]; then
        log "Wi-Fi hardware detected: $WIFI_DEVICES"
        
        # Install common Wi-Fi drivers
        apt install -y firmware-iwlwifi firmware-realtek firmware-atheros
        
        # Detect specific Wi-Fi chipsets
        if lspci | grep -i broadcom > /dev/null; then
            log "Broadcom Wi-Fi detected"
            apt install -y broadcom-sta-dkms
        fi
        
        if lspci | grep -i realtek > /dev/null; then
            log "Realtek Wi-Fi detected"
            apt install -y rtl8812au-dkms rtl8821ce-dkms
        fi
        
        # Restart NetworkManager
        systemctl restart NetworkManager
    else
        log "No Wi-Fi hardware detected"
    fi
}

# Configure audio drivers
configure_audio() {
    log "Configuring audio drivers..."
    
    # Detect audio hardware
    AUDIO_DEVICES=$(lspci | grep -i audio || true)
    
    if [[ -n "$AUDIO_DEVICES" ]]; then
        log "Audio hardware detected: $AUDIO_DEVICES"
        
        # Install audio drivers
        apt install -y alsa-utils pulseaudio pulseaudio-module-bluetooth
        
        # Configure PulseAudio
        cat > /etc/pulse/daemon.conf << EOF
# Theera OS PulseAudio Configuration
default-sample-format = s16le
default-sample-rate = 44100
alternate-sample-rate = 48000
default-sample-channels = 2
default-channel-map = front-left,front-right
high-priority = yes
nice-level = -11
realtime-scheduling = yes
realtime-priority = 5
rlimit-rtprio = 9
rlimit-rttime = 200000
EOF
        
        # Add user to audio group
        usermod -aG audio "$SUDO_USER"
    fi
}

# Configure Bluetooth
configure_bluetooth() {
    log "Configuring Bluetooth..."
    
    # Check for Bluetooth hardware
    if lsusb | grep -i bluetooth > /dev/null || lspci | grep -i bluetooth > /dev/null; then
        log "Bluetooth hardware detected"
        
        # Install Bluetooth drivers
        apt install -y bluetooth bluez bluez-tools
        
        # Configure Bluetooth
        cat > /etc/bluetooth/main.conf << EOF
[General]
Name = Theera OS
Class = 0x000100
DiscoverableTimeout = 0
PairableTimeout = 0
AutoConnect=true
FastConnectable=true

[Policy]
AutoEnable=true
EOF
        
        # Enable Bluetooth service
        systemctl enable bluetooth
        systemctl start bluetooth
    else
        log "No Bluetooth hardware detected"
    fi
}

# Configure power management
configure_power() {
    log "Configuring power management..."
    
    # Detect laptop
    if laptop-detect; then
        log "Laptop detected, installing power management tools"
        
        # Install TLP for advanced power management
        apt install -y tlp tlp-rdw
        
        # Configure TLP
        cat > /etc/tlp.conf << EOF
# Theera OS TLP Configuration for Laptops
TLP_ENABLE=1
TLP_DEFAULT_MODE=BAT
TLP_PERSISTENT_DEFAULT=0
DISK_IDLE_SECS_ON_AC=0
DISK_IDLE_SECS_ON_BAT=2
MAX_LOST_WORK_SECS_ON_AC=15
MAX_LOST_WORK_SECS_ON_BAT=60
CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_SCALING_GOVERNOR_ON_BAT=powersave
CPU_ENERGY_PERF_POLICY_ON_AC=performance
CPU_ENERGY_PERF_POLICY_ON_BAT=power
SCHED_POWERSAVE_ON_AC=0
SCHED_POWERSAVE_ON_BAT=1
NMI_WATCHDOG=0
WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=on
SOUND_POWER_SAVE_ON_AC=0
SOUND_POWER_SAVE_ON_BAT=1
RUNTIME_PM_ON_AC=on
RUNTIME_PM_ON_BAT=auto
USB_AUTOSUSPEND=1
USB_BLACKLIST_WWAN=1
RESTORE_DEVICE_STATE_ON_STARTUP=0
EOF
        
        # Enable TLP
        systemctl enable tlp
        systemctl start tlp
        
        # Install laptop-mode-tools as alternative
        apt install -y laptop-mode-tools
    else
        log "Desktop system detected, skipping laptop-specific power management"
    fi
}

# Configure printers and scanners
configure_printing() {
    log "Configuring printing and scanning support..."
    
    # Install CUPS and drivers
    apt install -y cups cups-browsed system-config-printer
    apt install -y printer-driver-all
    apt install -y hplip  # HP printers
    
    # Install scanning support
    apt install -y sane-utils simple-scan
    
    # Enable CUPS
    systemctl enable cups
    systemctl start cups
    
    # Add user to lpadmin group
    usermod -aG lpadmin "$SUDO_USER"
}

# Configure input devices
configure_input() {
    log "Configuring input devices..."
    
    # Configure touchpad
    if grep -i touchpad /proc/bus/input/devices > /dev/null; then
        log "Touchpad detected"
        
        # Install touchpad drivers
        apt install -y xserver-xorg-input-synaptics
        
        # Configure touchpad settings
        cat > /etc/X11/xorg.conf.d/40-touchpad.conf << EOF
Section "InputClass"
    Identifier "touchpad"
    Driver "synaptics"
    MatchIsTouchpad "on"
    Option "TapButton1" "1"
    Option "TapButton2" "3"
    Option "TapButton3" "2"
    Option "VertEdgeScroll" "on"
    Option "VertTwoFingerScroll" "on"
    Option "HorizEdgeScroll" "on"
    Option "HorizTwoFingerScroll" "on"
    Option "CircularScrolling" "on"
    Option "CircScrollTrigger" "2"
    Option "EmulateTwoFingerMinZ" "40"
    Option "EmulateTwoFingerMinW" "8"
    Option "CoastingSpeed" "0"
    Option "FingerLow" "30"
    Option "FingerHigh" "50"
    Option "MaxTapTime" "125"
EndSection
EOF
    fi
}

# Update initramfs and modules
update_system() {
    log "Updating system configuration..."
    
    # Update initramfs
    update-initramfs -u
    
    # Update module dependencies
    depmod -a
    
    # Update hardware database
    update-pciids
    update-usbids
    
    # Rebuild font cache
    fc-cache -f -v
}

# Main function
main() {
    log "Starting hardware detection and driver installation..."
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
        exit 1
    fi
    
    # Set SUDO_USER if not set
    if [[ -z "$SUDO_USER" ]]; then
        SUDO_USER="theera"
    fi
    
    # Update package lists
    apt update
    
    # Configure hardware components
    configure_graphics
    configure_wifi
    configure_audio
    configure_bluetooth
    configure_power
    configure_printing
    configure_input
    
    # Update system
    update_system
    
    log "Hardware configuration completed successfully!"
    log "Please reboot the system to apply all changes."
}

# Execute main function
main "$@"
