# Building Theera OS on Windows using WSL2

## Prerequisites
- Windows 10 version 2004+ or Windows 11
- WSL2 enabled
- Ubuntu 22.04 LTS in WSL2
- At least 16GB RAM and 100GB free disk space

## Step 1: Install WSL2 and Ubuntu

### Enable WSL2
Open PowerShell as Administrator and run:
```powershell
# Enable WSL feature
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Enable Virtual Machine Platform
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Restart your computer
shutdown /r /t 0
```

### Install Ubuntu 22.04 LTS
```powershell
# After restart, set WSL2 as default
wsl --set-default-version 2

# Install Ubuntu from Microsoft Store or command line
wsl --install -d Ubuntu-22.04
```

## Step 2: Configure WSL2 for Building

### Increase WSL2 Memory Allocation
Create or edit `%USERPROFILE%\.wslconfig`:
```ini
[wsl2]
memory=12GB
processors=4
swap=4GB
localhostForwarding=true
```

Restart WSL2:
```powershell
wsl --shutdown
wsl
```

### Launch Ubuntu and Update
```bash
# Update the system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y git wget curl
```

## Step 3: Clone Theera OS Project

```bash
# Navigate to your home directory
cd ~

# Clone the project (or copy from Windows)
git clone /mnt/e/os theera-os
# OR if you don't have git repo, copy the files:
cp -r /mnt/e/os theera-os

cd theera-os
```

## Step 4: Build the ISO

```bash
# Make the build script executable
chmod +x build-system/build-iso.sh

# Run the build process
sudo ./build-system/build-iso.sh
```

## Step 5: Access the Built ISO

The ISO will be created in the `output/` directory. You can access it from Windows:
```bash
# Check the build output
ls -la output/

# Copy to Windows desktop (optional)
cp output/theera-os-1.0.iso /mnt/c/Users/$USER/Desktop/
```

The ISO file will be available at:
- WSL path: `~/theera-os/output/theera-os-1.0.iso`
- Windows path: `\\wsl$\Ubuntu-22.04\home\<username>\theera-os\output\theera-os-1.0.iso`
