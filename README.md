# Theera OS - A Modern Linux Distribution

## Overview
Theera OS is a fully functional, production-grade Linux operating system built from scratch using the Linux kernel and Debian/Ubuntu as the base. It features a modern GNOME desktop environment, comprehensive hardware support, and is designed for daily use on laptops and desktops.

## Key Features
- **Desktop Environment**: GNOME with custom Theera branding
- **Package Management**: APT (primary), Snap, and Flatpak support
- **Security**: AppArmor, UFW firewall, Secure Boot compatibility
- **Hardware Support**: Automatic driver detection, proprietary driver support
- **Installation**: GUI installer (Ubiquity) with Live Boot mode
- **Boot Support**: UEFI and Legacy BIOS with Secure Boot

## Build Requirements
- Ubuntu 22.04+ or Debian 12+ host system
- 16GB+ RAM
- 100GB+ free disk space
- Internet connection for package downloads

## Quick Start
```bash
# Build on Ubuntu Live USB (Recommended)
# 1. Boot Ubuntu 22.04+ Live USB
# 2. Copy project files from external storage
# 3. Run build command:
sudo ./build-system/build-iso.sh

# The resulting ISO will be in output/theera-os.iso
```

## Project Structure
```
theera-os/
├── build-system/          # ISO build scripts and tools
├── config/                # System configuration files
├── branding/              # Theera OS branding assets
├── packages/              # Custom package definitions
├── scripts/               # Installation and setup scripts
├── live-config/           # Live system configuration
└── output/                # Build outputs (ISO files)
```

## Documentation
- [Build Guide](docs/BUILD.md)
- [Configuration Guide](docs/CONFIGURATION.md)
- [Development Guide](docs/DEVELOPMENT.md)
- [Security Features](docs/SECURITY.md)

## License
GPL v3.0 - See LICENSE file for details
