#!/usr/bin/env bash
# ==============================================================================
# Master Setup Script: Complete Interface Customization
# Run once to apply Desktop UI, Nautilus, Icons, Boot Splash, GRUB & Login Page
# ==============================================================================
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================================================"
echo "  FULL MACOS TAHOE SYSTEM & DESKTOP CUSTOMIZATION SUITE"
echo "========================================================================"

# Step 1: User desktop settings (runs as current user, no root needed)
echo ""
echo ">>> STEP 1: Applying Desktop Interface, Nautilus GTK4 & Icons..."
bash "$DIR/apply_desktop_theme.sh"

# Step 2: System bootloader, Plymouth splash, and GDM login page (runs with sudo)
echo ""
echo ">>> STEP 2: Applying macOS Boot Splash, GRUB & Login Screen..."
sudo bash "$DIR/setup_startup_and_login.sh"

echo ""
echo "========================================================================"
echo " COMPLETE MACOS TAHOE CUSTOMIZATION FINISHED SUCCESSFULLY!"
echo "========================================================================"
