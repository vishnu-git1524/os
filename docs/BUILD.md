# Theera OS Build Guide

This guide explains how to build the Theera OS ISO from source.

## Prerequisites

### System Requirements
- **Operating System**: Ubuntu 22.04+ or Debian 12+
- **RAM**: 16GB+ recommended (minimum 8GB)
- **Disk Space**: 100GB+ free space
- **CPU**: Multi-core processor recommended
- **Network**: High-speed internet connection

### Required Packages
The build script will automatically install these packages if missing:
- `live-build` - Debian Live system build tools
- `debootstrap` - Bootstrap a basic Debian/Ubuntu system
- `xorriso` - ISO 9660 filesystem manipulation
- `isolinux` - Bootloader for Linux on removable media
- `syslinux-utils` - Utilities for the syslinux bootloader
- `genisoimage` - Creates ISO-9660 CD-ROM filesystem images
- `memtest86+` - Memory testing tool
- `rsync` - File synchronization tool
- `wget` - Web file retrieval tool
- `curl` - Command line tool for transferring data

## Build Process

### 1. Clone Repository
```bash
git clone <repository-url>
cd theera-os
```

### 2. Run Build Script
```bash
sudo ./build-system/build-iso.sh
```

The build process includes the following stages:

1. **System Check**: Verifies requirements and installs missing packages
2. **Environment Setup**: Creates build directory and configuration
3. **Package Configuration**: Sets up package lists for different categories
4. **Live-Build Setup**: Configures the live-build system
5. **Chroot Build**: Creates the filesystem with all packages and configuration
6. **ISO Generation**: Creates the bootable ISO image
7. **Checksums**: Generates SHA256 and MD5 checksums

### 3. Build Output
The completed ISO will be located at:
```
output/theera-os-1.0.iso
output/theera-os-1.0.iso.sha256
output/theera-os-1.0.iso.md5
```

## Build Configuration

### Package Categories

#### Core System (`core.list.chroot`)
- Linux kernel and firmware
- Boot system (GRUB, casper)
- Installation system (Ubiquity)
- Network management
- Hardware support drivers

#### Desktop Environment (`desktop.list.chroot`)
- GNOME Shell and core applications
- GTK themes and extensions
- System utilities and tools

#### Development Tools (`development.list.chroot`)
- Programming languages (Python, Node.js, Go, Rust)
- Code editors (VS Code, GNOME Builder)
- Build tools and debuggers
- Version control systems

#### Security (`security.list.chroot`)
- AppArmor mandatory access control
- UFW firewall
- Security scanning tools
- Automatic update system

#### Multimedia (`multimedia.list.chroot`)
- Audio/video codecs
- Media players and editors
- Graphics and design tools

### Custom Configuration

#### System Settings
- **dconf**: GNOME desktop settings and defaults
- **AppArmor**: Security profiles for applications
- **NetworkManager**: Network configuration
- **systemd**: Service management and timers

#### Branding
- **Plymouth**: Boot splash screen
- **Wallpapers**: Desktop and lock screen backgrounds
- **Themes**: Custom GTK and GNOME Shell themes
- **Icons**: Custom icon sets and logos

## Customization

### Adding Packages
Edit the appropriate package list file in `config/package-lists/`:
```bash
# Add to desktop.list.chroot
echo "new-package-name" >> config/package-lists/desktop.list.chroot
```

### Custom Configuration Files
Place configuration files in the appropriate directory:
- `config/chroot/`: Files copied to the live system
- `config/binary/`: Files copied to the ISO root

### Hooks and Scripts
Custom scripts can be added to:
- `config/hooks/normal/`: Executed during chroot build
- `config/hooks/live/`: Executed in live environment

## Troubleshooting

### Common Issues

#### Insufficient Disk Space
```
Error: No space left on device
```
**Solution**: Ensure at least 100GB free space and clean `/tmp` directory.

#### Package Download Failures
```
Error: Failed to fetch package
```
**Solution**: Check internet connection and try again. Some mirrors may be temporarily unavailable.

#### Permission Errors
```
Error: Permission denied
```
**Solution**: Ensure script is run with `sudo` and build directory has proper permissions.

#### Memory Issues
```
Error: Cannot allocate memory
```
**Solution**: Increase available RAM or add swap space:
```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Debugging Build Issues

#### Enable Verbose Output
```bash
sudo ./build-system/build-iso.sh --verbose
```

#### Check Build Logs
```bash
tail -f output/build.log
```

#### Manual Cleanup
```bash
sudo rm -rf build/
```

### Build Optimization

#### Parallel Processing
Set the number of parallel jobs:
```bash
export MAKEFLAGS="-j$(nproc)"
```

#### Local Package Cache
Use local APT cache to speed up rebuilds:
```bash
sudo apt-cacher-ng
```

## Advanced Configuration

### Custom Kernel
To use a custom kernel:
1. Add kernel packages to `core.list.chroot`
2. Configure kernel parameters in live-build config
3. Update initramfs hooks if needed

### Custom Repository
To add a custom repository:
1. Add repository to `config/chroot/etc/apt/sources.list.d/`
2. Add GPG keys to `config/chroot/etc/apt/trusted.gpg.d/`
3. Update package lists accordingly

### Security Hardening
Additional security measures:
1. Enable Secure Boot signing
2. Configure additional AppArmor profiles
3. Set up fail2ban and intrusion detection
4. Enable audit logging

## Testing

### Virtual Machine Testing
Test the ISO in a virtual machine:
```bash
# QEMU
qemu-system-x86_64 -cdrom output/theera-os-1.0.iso -m 4096 -enable-kvm

# VirtualBox
VBoxManage createvm --name "Theera-Test" --register
VBoxManage modifyvm "Theera-Test" --memory 4096 --vram 128
VBoxManage storagectl "Theera-Test" --name "IDE" --add ide
VBoxManage storageattach "Theera-Test" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium output/theera-os-1.0.iso
```

### USB Boot Testing
Create bootable USB:
```bash
sudo dd if=output/theera-os-1.0.iso of=/dev/sdX bs=4M status=progress
sync
```

### Hardware Compatibility Testing
Test on various hardware configurations:
- Different CPU architectures
- Various graphics cards (Intel, NVIDIA, AMD)
- Different storage types (HDD, SSD, NVMe)
- Various network adapters

## Performance Optimization

### Build Performance
- Use SSD storage for build directory
- Increase available RAM
- Use local package mirrors
- Enable ccache for compilation

### Runtime Performance
- Optimize package selection
- Configure swappiness for SSD systems
- Enable hardware acceleration
- Tune kernel parameters

## Security Considerations

### Build Environment Security
- Use isolated build environment
- Verify package signatures
- Scan for malware
- Use reproducible builds when possible

### Distribution Security
- Sign ISO images
- Provide secure download channels
- Regular security updates
- Security advisory system
