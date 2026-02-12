#!/bin/bash

# System Info Script
# Displays basic system information

echo "=================================="
echo "        System Information"
echo "=================================="
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
