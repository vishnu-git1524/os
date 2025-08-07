# Theera OS Development Guide

This guide provides information for developers who want to contribute to Theera OS or create custom derivatives.

## Development Environment Setup

### Requirements
- Ubuntu 22.04+ or Debian 12+ development machine
- 16GB+ RAM (32GB recommended)
- 200GB+ free disk space
- Fast internet connection
- Git version control

### Setting Up Development Environment
```bash
# Clone the repository
git clone https://github.com/theera-os/theera-os.git
cd theera-os

# Install development dependencies
sudo apt update
sudo apt install -y git build-essential devscripts debhelper

# Install live-build and ISO creation tools
sudo apt install -y live-build debootstrap xorriso
```

## Project Structure

### Core Directories
```
theera-os/
├── build-system/          # ISO build automation
│   ├── build-iso.sh      # Main build script
│   └── helpers/          # Build helper scripts
├── config/               # System configuration
│   ├── chroot/          # Files for live system
│   ├── binary/          # Files for ISO root
│   └── live-build/      # Live-build configuration
├── packages/            # Package lists and definitions
│   ├── core.list        # Core system packages
│   ├── desktop.list     # Desktop environment
│   ├── development.list # Development tools
│   └── applications.list # User applications
├── branding/            # Visual branding assets
│   ├── wallpapers/      # Desktop wallpapers
│   ├── icons/           # Custom icons
│   ├── themes/          # GTK themes
│   └── plymouth/        # Boot splash
├── scripts/             # System configuration scripts
│   ├── post-install-config.sh  # Post-installation setup
│   └── hardware-setup.sh       # Hardware detection
└── docs/               # Documentation
```

### Configuration Files
- **dconf settings**: `config/chroot/etc/dconf/db/local.d/`
- **systemd services**: `config/chroot/etc/systemd/system/`
- **AppArmor profiles**: `config/chroot/etc/apparmor.d/`
- **Network configuration**: `config/chroot/etc/NetworkManager/`

## Building Custom ISOs

### Modifying Package Selection

#### Adding Packages
```bash
# Add to appropriate package list
echo "new-package-name" >> packages/applications.list

# Or edit the file directly
vim packages/desktop.list
```

#### Removing Packages
```bash
# Comment out or remove from package lists
sed -i 's/^unwanted-package/#unwanted-package/' packages/core.list
```

#### Custom Package Categories
Create new package list files:
```bash
# Create custom category
cat > packages/gaming.list << EOF
steam
lutris
wine
winetricks
gamemode
EOF
```

### Customizing Desktop Environment

#### GNOME Settings
Edit `config/chroot/etc/dconf/db/local.d/00-theera-defaults`:
```ini
[org/gnome/desktop/interface]
gtk-theme='Custom-Theme'
icon-theme='Custom-Icons'

[org/gnome/shell]
favorite-apps=['custom-app.desktop']
```

#### Adding Extensions
```bash
# Download extension to config/chroot/usr/share/gnome-shell/extensions/
mkdir -p config/chroot/usr/share/gnome-shell/extensions/extension-name
# Extract extension files there
```

### Custom Branding

#### Wallpapers
```bash
# Add wallpapers to branding/wallpapers/
cp my-wallpaper.jpg branding/wallpapers/theera-wallpaper.jpg

# Update dconf settings to use new wallpaper
# Edit config/chroot/etc/dconf/db/local.d/00-theera-defaults
```

#### Plymouth Boot Splash
```bash
# Modify config/chroot/usr/share/plymouth/themes/theera/
# Edit theera.plymouth file for configuration
# Add custom images and animations
```

#### GTK Themes
```bash
# Add custom theme to config/chroot/usr/share/themes/
mkdir -p config/chroot/usr/share/themes/My-Theme
# Copy theme files
```

### Advanced Customization

#### Custom Repositories
Add repository configuration:
```bash
# Create repository file
cat > config/chroot/etc/apt/sources.list.d/custom.list << EOF
deb https://my-repo.example.com/ubuntu jammy main
EOF

# Add GPG key
cp my-repo-key.gpg config/chroot/etc/apt/trusted.gpg.d/
```

#### System Services
```bash
# Add custom systemd service
cat > config/chroot/etc/systemd/system/my-service.service << EOF
[Unit]
Description=My Custom Service
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/my-script.sh

[Install]
WantedBy=multi-user.target
EOF
```

#### Build Hooks
Create custom build hooks:
```bash
# Create hook script
cat > config/hooks/normal/999-custom.hook.chroot << 'EOF'
#!/bin/bash
# Custom configuration hook
echo "Running custom configuration..."

# Add custom logic here
systemctl enable my-service
EOF

chmod +x config/hooks/normal/999-custom.hook.chroot
```

## Testing and Debugging

### Virtual Machine Testing
```bash
# Test with QEMU
qemu-system-x86_64 \
  -cdrom output/theera-os-1.0.iso \
  -m 4096 \
  -enable-kvm \
  -boot d

# Test with VirtualBox
VBoxManage createvm --name "Theera-Test" --register
VBoxManage modifyvm "Theera-Test" --memory 4096 --vram 128
# ... additional VirtualBox configuration
```

### Debug Build Issues

#### Verbose Build Output
```bash
sudo ./build-system/build-iso.sh --verbose
```

#### Chroot Debugging
```bash
# Enter build chroot for debugging
sudo chroot build/chroot /bin/bash

# Test packages and configuration
apt list --installed
systemctl status
```

#### Log Analysis
```bash
# Check build logs
tail -f output/build.log

# Check specific errors
grep -i error output/build.log
grep -i fail output/build.log
```

## Contributing to Theera OS

### Development Workflow

#### Setting Up Git
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/yourusername/theera-os.git
cd theera-os

# Add upstream remote
git remote add upstream https://github.com/theera-os/theera-os.git
```

#### Creating Features
```bash
# Create feature branch
git checkout -b feature/my-new-feature

# Make changes
# ... edit files ...

# Commit changes
git add .
git commit -m "Add new feature: description"

# Push to your fork
git push origin feature/my-new-feature

# Create pull request on GitHub
```

#### Code Standards
- Use clear, descriptive commit messages
- Follow shell scripting best practices
- Test changes in virtual machines
- Document new features and configurations
- Maintain backward compatibility when possible

### Package Maintenance

#### Adding New Applications
1. Research package availability and dependencies
2. Add to appropriate package list
3. Test installation and functionality
4. Update documentation
5. Create configuration if needed

#### Updating Base System
1. Test new Ubuntu/Debian base versions
2. Update package lists for compatibility
3. Test all core functionality
4. Update documentation and changelogs

### Security Considerations

#### Security Reviews
- Review all package additions for security implications
- Test AppArmor profiles and firewall rules
- Verify secure defaults for all services
- Audit custom scripts and configurations

#### Vulnerability Management
- Monitor security advisories for included packages
- Implement timely security updates
- Test security patches before release
- Maintain security documentation

## Release Management

### Version Control
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Tag releases in Git
- Maintain changelog
- Create release branches for stability

### Quality Assurance

#### Pre-Release Testing
1. **Build Testing**: Clean builds on multiple systems
2. **Installation Testing**: Test installation on various hardware
3. **Functionality Testing**: Verify all major features work
4. **Performance Testing**: Check boot time and resource usage
5. **Security Testing**: Verify security features and defaults

#### Hardware Testing Matrix
- Various laptop models (Dell, HP, Lenovo, etc.)
- Desktop systems with different graphics cards
- Different storage types (HDD, SSD, NVMe)
- Various Wi-Fi chipsets
- USB and external device compatibility

### Documentation
- Keep all documentation up to date
- Provide clear installation instructions
- Document known issues and workarounds
- Maintain troubleshooting guides

## Advanced Topics

### Custom Kernel
```bash
# Building custom kernel
apt source linux-image-generic
cd linux-*

# Configure kernel
make menuconfig

# Build packages
make -j$(nproc) bindeb-pkg

# Add to package list
echo "linux-image-custom" >> packages/core.list
```

### Package Backports
```bash
# Create backport of newer package
apt source package-name

# Modify for compatibility
dch -b -D jammy-backports "Backport for Theera OS"

# Build package
debuild -uc -us

# Add to custom repository
```

### Automated Testing
```bash
# Create test automation
#!/bin/bash
# test-iso.sh

# Automated ISO testing script
qemu-system-x86_64 \
  -cdrom "$1" \
  -m 2048 \
  -display vnc=:1 \
  -boot d \
  -netdev user,id=net0 \
  -device e1000,netdev=net0

# Add test scenarios and validation
```

## Tools and Utilities

### Useful Development Tools
- **live-build**: Debian Live system builder
- **debootstrap**: Create minimal Debian/Ubuntu systems
- **schroot**: Manage chroot environments
- **pbuilder**: Build packages in clean environments
- **lintian**: Check Debian packages for policy violations
- **piuparts**: Test package installation/removal

### Debugging Commands
```bash
# Check package dependencies
apt-cache depends package-name
apt-cache rdepends package-name

# Verify file conflicts
dpkg -S /path/to/file

# Check service status
systemctl status service-name
journalctl -u service-name

# Monitor system resources
htop
iotop
nethogs
```

This development guide provides the foundation for contributing to and customizing Theera OS. For specific questions or advanced topics, consult the project documentation or contact the development team.
