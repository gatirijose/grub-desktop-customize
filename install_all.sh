#!/usr/bin/env bash
# ==============================================================================
# Master Setup Script: Complete Interface Customization
# Run once to apply Desktop UI, Windows Shortcuts, Startup Splash & Login Page
# ==============================================================================
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TITLE=""
while [[ $# -gt 0 ]]; do
  case $1 in
    -t|--title)
      TITLE="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

if [ -z "$TITLE" ] && [ -t 0 ]; then
  echo ""
  echo "========================================================================"
  echo "  FULL SYSTEM & DESKTOP CUSTOMIZATION SUITE"
  echo "========================================================================"
  read -p "Enter Developer Title for power-on splash [Default: JOSEPH // SOFTWARE DEVELOPER]: " INPUT_TITLE
  TITLE="${INPUT_TITLE:-JOSEPH // SOFTWARE DEVELOPER}"
fi

echo "========================================================================"
echo " Starting Full UI Customization (Desktop, Shortcuts, Startup, Login)"
[ -n "$TITLE" ] && echo " Developer Title: $TITLE"
echo "========================================================================"

# Step 1: User desktop settings (runs as current user)
echo ""
echo ">>> STEP 1: Applying Desktop Interface & Keybindings..."
bash "$DIR/apply_desktop_theme.sh"

# Step 2: System bootloader, Plymouth splash, and GDM login page (runs with sudo)
echo ""
echo ">>> STEP 2: Applying Startup UI, Silent Boot, and Login Screen..."
if [ -n "$TITLE" ]; then
  sudo bash "$DIR/setup_startup_and_login.sh" --title "$TITLE"
else
  sudo bash "$DIR/setup_startup_and_login.sh"
fi

echo ""
echo "========================================================================"
echo " COMPLETE CUSTOMIZATION FINISHED SUCCESSFULLY!"
echo "========================================================================"
