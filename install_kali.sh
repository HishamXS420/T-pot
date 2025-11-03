#!/usr/bin/env bash

# T-Pot Quick Install Script for Kali Linux
# This is a convenience wrapper that validates Kali and runs the installer

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     T-Pot Honeypot - Kali Linux Quick Installer           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check if running on Kali
if ! grep -q "ID=kali" /etc/os-release; then
    echo "❌ ERROR: This script is designed for Kali Linux only!"
    echo "   Detected: $(awk -F= '/^NAME/{print $2}' /etc/os-release | tr -d '"')"
    echo ""
    exit 1
fi

echo "✓ Detected Kali GNU/Linux"
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo "❌ ERROR: Do not run this script as root!"
    echo "   T-Pot must be installed by a regular user with sudo privileges."
    echo ""
    exit 1
fi

echo "✓ Running as non-root user: $(whoami)"
echo ""

# Check if user has sudo privileges
if ! sudo -n true 2>/dev/null; then
    echo "⚠ This script requires sudo privileges."
    echo "  You will be prompted for your password."
    echo ""
fi

# Update system
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Updating Kali Linux system..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sudo apt update
echo ""

# Ask installation type
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Select T-Pot Installation Type"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Available installation types:"
echo "  h - HIVE    : Central management server (requires web credentials)"
echo "  s - SENSOR  : Data collector node (no credentials needed)"
echo "  l - LLM     : With language model (requires web credentials)"
echo "  i - MINI    : Lightweight installation (requires web credentials)"
echo "  m - MOBILE  : Mobile deployment (no credentials needed)"
echo "  t - TARPIT  : Slow down attackers (requires web credentials)"
echo ""

read -p "Enter installation type [h/s/l/i/m/t]: " INSTALL_TYPE

# Validate installation type
case ${INSTALL_TYPE,,} in
    h|s|l|i|m|t)
        echo "✓ Selected type: ${INSTALL_TYPE,,}"
        ;;
    *)
        echo "❌ Invalid installation type!"
        exit 1
        ;;
esac

echo ""

# Get credentials if needed
if [[ ${INSTALL_TYPE,,} =~ ^[hlit]$ ]]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Step 3: Web Interface Credentials"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    read -p "Enter web interface username: " WEB_USER
    read -sp "Enter web interface password: " WEB_PASS
    echo ""
    read -sp "Confirm password: " WEB_PASS_CONFIRM
    echo ""
    
    if [[ "$WEB_PASS" != "$WEB_PASS_CONFIRM" ]]; then
        echo "❌ Passwords do not match!"
        exit 1
    fi
    
    if [[ -z "$WEB_USER" ]] || [[ -z "$WEB_PASS" ]]; then
        echo "❌ Username and password cannot be empty!"
        exit 1
    fi
    
    echo "✓ Credentials set"
    echo ""
    
    INSTALL_CMD="./install.sh -s -t ${INSTALL_TYPE,,} -u \"$WEB_USER\" -p \"$WEB_PASS\""
else
    INSTALL_CMD="./install.sh -s -t ${INSTALL_TYPE,,}"
fi

# Confirmation
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installation Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "OS: Kali GNU/Linux"
echo "User: $(whoami)"
echo "Type: ${INSTALL_TYPE,,}"
if [[ ${INSTALL_TYPE,,} =~ ^[hlit]$ ]]; then
    echo "Web User: $WEB_USER"
fi
echo ""
echo "⚠  WARNING: Your system will be rebooted after installation!"
echo ""
read -p "Proceed with installation? [y/N]: " CONFIRM

if [[ ${CONFIRM,,} != "y" ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Starting T-Pot Installation..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Run installation
if [[ ${INSTALL_TYPE,,} =~ ^[hlit]$ ]]; then
    ./install.sh -s -t "${INSTALL_TYPE,,}" -u "$WEB_USER" -p "$WEB_PASS"
else
    ./install.sh -s -t "${INSTALL_TYPE,,}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installation Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
