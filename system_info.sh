#!/bin/bash

# ============================================================================
# System Information Display Script
# Displays system hardware and software information with optional GPU drivers
# ============================================================================

# ============================================================================
# FUNCTION DEFINITIONS
# ============================================================================

print_header() {
    echo "=================================="
    echo "        System Information"
    echo "=================================="
    echo ""
}

print_user_info() {
    echo "👤 User:"
    echo "   $(whoami)"
    echo ""
}

print_hostname() {
    echo "🖥️  Hostname:"
    echo "   $(hostname)"
    echo ""
}

print_os() {
    echo "💿 Operating System:"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "   $PRETTY_NAME"
    else
        echo "   $(uname -s)"
    fi
    echo ""
}

print_kernel() {
    echo "⚙️  Kernel Version:"
    echo "   $(uname -r)"
    echo ""
}

print_uptime() {
    echo "⏱️  Uptime:"
    echo "   $(uptime -p 2>/dev/null || uptime | awk -F'( |,|:)+' '{print $6,$7",",$8,"hours,",$9,"minutes"}')"
    echo ""
}

print_cpu() {
    echo "🔧 CPU:"
    local cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)
    local cpu_cores=$(grep -c "^processor" /proc/cpuinfo)
    echo "   Model: $cpu_model"
    echo "   Cores: $cpu_cores"
    echo ""
}

print_ram() {
    echo "💾 Memory (RAM):"
    local total_ram=$(free -h | awk '/^Mem:/ {print $2}')
    local used_ram=$(free -h | awk '/^Mem:/ {print $3}')
    local free_ram=$(free -h | awk '/^Mem:/ {print $4}')
    echo "   Total: $total_ram"
    echo "   Used:  $used_ram"
    echo "   Free:  $free_ram"
    echo ""
}

check_gpu_nvidia() {
    if command -v nvidia-smi &> /dev/null; then
        local nvidia_gpu=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)
        if [ ! -z "$nvidia_gpu" ]; then
            echo "   $nvidia_gpu"
            return 0
        fi
    fi
    return 1
}

check_gpu_lspci() {
    if command -v lspci &> /dev/null; then
        while IFS= read -r line; do
            local gpu_name=$(echo "$line" | sed 's/^[0-9a-f:\.]*\s*VGA compatible controller:\s*//' | sed 's/^[0-9a-f:\.]*\s*3D controller:\s*//')
            if [ ! -z "$gpu_name" ]; then
                echo "   $gpu_name"
                return 0
            fi
        done < <(lspci | grep -i 'vga\|3d')
    fi
    return 1
}

check_gpu_procfs() {
    if [ -d "/proc/driver/nvidia/gpus" ]; then
        for gpu_dir in /proc/driver/nvidia/gpus/*; do
            if [ -f "$gpu_dir/information" ]; then
                local gpu_model=$(grep "Model:" "$gpu_dir/information" | cut -d':' -f2 | xargs)
                if [ ! -z "$gpu_model" ]; then
                    echo "   $gpu_model"
                    return 0
                fi
            fi
        done
    fi
    return 1
}

print_gpu() {
    echo "🎮 GPU:"
    
    check_gpu_nvidia && return
    check_gpu_lspci && return
    check_gpu_procfs && return
    
    # No GPU found
    echo "⚠️  No GPU detected."
}
# ============================================================================
# GPU DRIVER INSTALLATION FUNCTIONS
# ============================================================================

install_amd_drivers() {
    echo "🟥 AMD GPU selected."
    echo "This will install open-source AMD drivers (mesa + firmware)."
    read -p "Continue? (y/n): " confirm
    
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        sudo dnf install -y \
            mesa-dri-drivers \
            mesa-vulkan-drivers \
            mesa-va-drivers \
            mesa-vdpau-drivers \
            linux-firmware
        echo "✅ AMD drivers installation finished. Reboot recommended."
    else
        echo "⏭️  Skipped AMD driver installation."
    fi
}

install_nvidia_drivers() {
    echo "🟩 NVIDIA GPU selected."
    echo "This will enable RPM Fusion and install NVIDIA drivers."
    read -p "Continue? (y/n): " confirm
    
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        sudo dnf install -y \
            https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
            https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
        echo "✅ NVIDIA drivers installed. Reboot REQUIRED."
    else
        echo "⏭️  Skipped NVIDIA driver installation."
    fi
}

prompt_driver_installation() {
    echo "Do you want to try installing GPU drivers?"
    read -p "Enter GPU type (amd / nvidia / skip): " gpu_type
    
    case "$gpu_type" in
        amd|AMD)
            install_amd_drivers
            ;;
        nvidia|NVIDIA)
            install_nvidia_drivers
            ;;
        skip|SKIP)
            echo "⏭️  GPU driver installation skipped."
            ;;
        *)
            echo "❌ Invalid option. Please enter amd, nvidia, or skip."
            ;;
    esac
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

print_header
print_user_info
print_hostname
print_os
print_kernel
print_uptime
print_cpu
print_ram
print_gpu
check_gpu_nvidia && prompt_driver_installation

echo "=================================="

