#!/usr/bin/env bash
# ==============================================================================
# Master Setup Script: Complete Interface Customization
# Run once to apply Desktop UI, Windows Shortcuts, Startup Splash & Login Page
# ==============================================================================
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================================================"
echo " Starting Full UI Customization (Desktop, Shortcuts, Startup, Login)"
echo "========================================================================"

# Step 1: User desktop settings (runs as current user)
echo ""
echo ">>> STEP 1: Applying Desktop Interface & Keybindings..."
bash "$DIR/apply_desktop_theme.sh"

# Step 2: System bootloader, Plymouth splash, and GDM login page (runs with sudo)
echo ""
echo ">>> STEP 2: Applying Startup UI, Silent Boot, and Login Screen..."
sudo bash "$DIR/setup_startup_and_login.sh"

echo ""
echo "========================================================================"
echo " COMPLETE CUSTOMIZATION FINISHED SUCCESSFULLY!"
echo "========================================================================"
