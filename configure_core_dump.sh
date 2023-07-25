#!/bin/bash

# Function to check if available memory is greater than storage
check_memory_vs_storage() {
    local total_memory
    local total_storage

    total_memory=$(free -m | awk '/^Mem:/{print $2}')
    total_storage=$(df -B 1MB --output=size / | tail -n 1)

    if [ "$total_memory" -gt "$total_storage" ]; then
        echo "Error: Available memory ($total_memory MB) is greater than storage ($total_storage MB). Cannot proceed."
        exit 1
    fi
}

# Function to configure core dump
configure_core_dump() {
    # Create Core Dump Directory
    sudo mkdir -p /var/coredumps
    sudo chmod 0755 /var/coredumps

    # Enable Core Dump
    echo "* soft core unlimited" | sudo tee -a /etc/security/limits.conf

    # Adjust Core Dump Pattern
    echo "kernel.core_pattern=/var/coredumps/core.%e.%p.%t" | sudo tee -a /etc/sysctl.conf

    # Set Core Dump Permission
    echo "fs.suid_dumpable=2" | sudo tee -a /etc/sysctl.conf

    # Load New Sysctl Settings
    sudo sysctl --system
}

# Main script starts here
check_memory_vs_storage
configure_core_dump

echo "Core dump configuration completed successfully."
