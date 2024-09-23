#!/bin/bash

# Function to check if nested virtualization is enabled
check_nested_virt() {
    local processor_type=$1
    if [ "$processor_type" == "intel" ]; then
        if [ -f "/sys/module/kvm_intel/parameters/nested" ]; then
            cat /sys/module/kvm_intel/parameters/nested
        else
            echo "N"
        fi
    elif [ "$processor_type" == "amd" ]; then
        if [ -f "/sys/module/kvm_amd/parameters/nested" ]; then
            cat /sys/module/kvm_amd/parameters/nested
        else
            echo "0"
        fi
    else
        echo "unknown"
    fi
}

# Detect processor type
if grep -q "vendor_id.*GenuineIntel" /proc/cpuinfo; then
    processor_type="intel"
    echo "Intel processor detected."
elif grep -q "vendor_id.*AuthenticAMD" /proc/cpuinfo; then
    processor_type="amd"
    echo "AMD processor detected."
else
    processor_type="unknown"
    echo "Unable to determine processor type."
fi

# Check and enable nested virtualization if necessary
if [ "$processor_type" != "unknown" ]; then
    nested_status=$(check_nested_virt $processor_type)
    if [ "$processor_type" == "intel" ] && [ "$nested_status" != "Y" ]; then
        echo "Enabling nested virtualization for Intel..."
        sudo modprobe -r kvm_intel
        sudo modprobe kvm_intel nested=1
        echo "options kvm-intel nested=1" | sudo tee /etc/modprobe.d/kvm-intel.conf
    elif [ "$processor_type" == "amd" ] && [ "$nested_status" != "1" ]; then
        echo "Enabling nested virtualization for AMD..."
        sudo modprobe -r kvm_amd
        sudo modprobe kvm_amd nested=1
        echo "options kvm-amd nested=1" | sudo tee /etc/modprobe.d/kvm-amd.conf
    else
        echo "Nested virtualization is already enabled for $processor_type."
    fi
else
    echo "Skipping nested virtualization setup due to unknown processor type."
fi

# Update system
sudo pacman -Syu --noconfirm

# Install required packages
sudo pacman -S --noconfirm qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat ebtables iptables libguestfs

# Enable and start libvirtd service
sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service

# Add user to libvirt group
sudo usermod -aG libvirt $USER

# Edit libvirtd.conf to allow non-root users
sudo sed -i 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf

# Restart libvirtd service
sudo systemctl restart libvirtd.service

echo "Installation complete. Please log out and log back in for group changes to take effect."
