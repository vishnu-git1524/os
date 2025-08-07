# Theera OS - Ubuntu Live USB Build Guide

Since you're using Ubuntu Live USB to build Theera OS, here's your streamlined process:

## 🚀 Quick Start

### 1. Prepare Ubuntu Live USB
- Download Ubuntu 22.04 LTS ISO
- Create bootable USB with persistence (32GB+ recommended)
- Boot from USB and select "Try Ubuntu"

### 2. Copy Project Files
```bash
# Mount your external storage
sudo mkdir /mnt/external
sudo mount /dev/sdX1 /mnt/external

# Copy Theera OS project
cp -r /mnt/external/theera-os ~/theera-os
cd ~/theera-os
```

### 3. Build Theera OS
```bash
# Install dependencies and build
sudo apt update
sudo apt install -y git curl wget
sudo ./build-system/build-iso.sh
```

### 4. Get Your ISO
```bash
# After 30-60 minutes, your ISO will be ready:
ls -la output/theera-os-1.0.iso

# Copy to external storage
cp output/theera-os-1.0.iso /mnt/external/
```

## 📋 Requirements
- **RAM**: 16GB+ recommended (8GB minimum)
- **Storage**: 25GB+ free space for build
- **Internet**: Stable connection for downloads
- **Time**: 30-90 minutes depending on speed

## 🎯 Why This Approach is Best
- ✅ **No WSL issues** - pure Linux environment
- ✅ **Better performance** - direct hardware access
- ✅ **More reliable** - no Windows interference
- ✅ **Clean build** - fresh Ubuntu system
- ✅ **Easy testing** - test your ISO immediately

## 📚 Complete Documentation
See `docs/BUILD-LIVE-USB.md` for detailed instructions and troubleshooting.

## 🔄 After Build
Once you have `theera-os-1.0.iso`:
1. Create bootable USB with Rufus
2. Test in VM or real hardware  
3. Install Theera OS or use as Live system

Happy building! 🎉
