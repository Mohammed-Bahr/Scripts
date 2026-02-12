#!/bin/bash

# System Info Script
# Displays basic system information

echo "=================================="
echo "        System Information"
echo "=================================="
echo ""

# Username
echo "👤 User:"
echo "   $(whoami)"
echo ""

# Hostname
echo "🖥️  Hostname:"
echo "   $(hostname)"
echo ""

# Operating System
echo "💿 Operating System:"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "   $PRETTY_NAME"
else
    echo "   $(uname -s)"
fi
echo ""

# Kernel Version
echo "⚙️  Kernel Version:"
echo "   $(uname -r)"
echo ""

# Uptime
echo "⏱️  Uptime:"
echo "   $(uptime -p 2>/dev/null || uptime | awk -F'( |,|:)+' '{print $6,$7",",$8,"hours,",$9,"minutes"}')"
echo ""

# CPU Information
echo "🔧 CPU:"
cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)
cpu_cores=$(grep -c "^processor" /proc/cpuinfo)
echo "   Model: $cpu_model"
echo "   Cores: $cpu_cores"
echo ""

# GPU Information
echo "🎮 GPU:"
gpu_found=false

# Method 1: Check nvidia-smi (most reliable for NVIDIA GPUs)
if command -v nvidia-smi &> /dev/null; then
    nvidia_gpu=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)
    if [ ! -z "$nvidia_gpu" ]; then
        echo "   $nvidia_gpu"
        gpu_found=true
    fi
fi

# Method 2: Check lspci for all VGA/3D controllers
if command -v lspci &> /dev/null; then
    while IFS= read -r line; do
        # Extract GPU name, removing the PCI address and "VGA compatible controller:" prefix
        gpu_name=$(echo "$line" | sed 's/^[0-9a-f:\.]*\s*VGA compatible controller:\s*//' | sed 's/^[0-9a-f:\.]*\s*3D controller:\s*//')
        if [ ! -z "$gpu_name" ]; then
            echo "   $gpu_name"
            gpu_found=true
        fi
    done < <(lspci | grep -i 'vga\|3d')
fi

# Method 3: Check /proc/driver/nvidia/gpus (NVIDIA specific)
if [ "$gpu_found" = false ] && [ -d "/proc/driver/nvidia/gpus" ]; then
    for gpu_dir in /proc/driver/nvidia/gpus/*; do
        if [ -f "$gpu_dir/information" ]; then
            gpu_model=$(grep "Model:" "$gpu_dir/information" | cut -d':' -f2 | xargs)
            if [ ! -z "$gpu_model" ]; then
                echo "   $gpu_model"
                gpu_found=true
            fi
        fi
    done
fi

# If no GPU detected
if [ "$gpu_found" = false ]; then
    echo "   No GPU detected or unable to query GPU info"
fi
echo ""

# RAM Information
echo "💾 Memory (RAM):"
total_ram=$(free -h | awk '/^Mem:/ {print $2}')
used_ram=$(free -h | awk '/^Mem:/ {print $3}')
free_ram=$(free -h | awk '/^Mem:/ {print $4}')
echo "   Total: $total_ram"
echo "   Used:  $used_ram"
echo "   Free:  $free_ram"
echo ""

echo "=================================="