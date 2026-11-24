#!/usr/bin/env bash
# ==============================================================================
# Master Setup Script: Complete Interface Customization
# Run once to apply Desktop UI, Nautilus, Icons, Boot Splash, GRUB & Login Page
# ==============================================================================
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ORIGINAL_USER=""
ORIGINAL_HOME=""
if [ "$(id -u)" -eq 0 ] && [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
  ORIGINAL_USER="$SUDO_USER"
  ORIGINAL_HOME=$(getent passwd "$ORIGINAL_USER" | cut -d: -f6)
fi

if [ ! -r /etc/os-release ]; then
  echo "ERROR: Cannot identify this Linux distribution." >&2
  exit 1
fi
# shellcheck source=/dev/null
. /etc/os-release

if [ "${ID:-}" = "arch" ] || [[ " ${ID_LIKE:-} " == *" arch "* ]]; then
  DISTRO_FAMILY="arch"
  PACKAGES=(git python python-cairo imagemagick dconf grub plymouth mkinitcpio gnome-shell gdm)
elif [ "${ID:-}" = "debian" ] || [ "${ID:-}" = "ubuntu" ] || [[ " ${ID_LIKE:-} " == *" debian "* ]]; then
  DISTRO_FAMILY="debian"
  PACKAGES=(git python3 python3-cairo imagemagick dconf grub-pc grub-common plymouth gnome-shell gdm3)
else
  echo "ERROR: This installer supports Arch Linux and Debian/Ubuntu only." >&2
  echo "Detected distribution: ${PRETTY_NAME:-${ID:-unknown}}" >&2
  exit 1
fi

missing=()
if [ "$DISTRO_FAMILY" = "arch" ]; then
  required_commands=(git python3 plymouth-set-default-theme grub-mkconfig gsettings)
else
  required_commands=(git python3 plymouth-set-default-theme update-grub gsettings)
fi
for package in "${required_commands[@]}"; do
  if ! command -v "$package" >/dev/null 2>&1; then
    missing+=("$package")
  fi
done

if [ "${#missing[@]}" -gt 0 ]; then
  echo "==> Installing missing system dependencies for $DISTRO_FAMILY..."
  if [ "$DISTRO_FAMILY" = "arch" ]; then
    sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
  else
    sudo apt-get update
    sudo apt-get install -y "${PACKAGES[@]}"
  fi
fi

echo "========================================================================"
echo "  FULL MACOS TAHOE SYSTEM & DESKTOP CUSTOMIZATION SUITE"
echo "========================================================================"

# Step 1: User desktop settings (must run as the logged-in user, never as root)
if [ -n "$ORIGINAL_USER" ]; then
  echo "==> Preparing desktop settings for $ORIGINAL_USER..."
  runuser -u "$ORIGINAL_USER" -- env \
    HOME="$ORIGINAL_HOME" \
    USER="$ORIGINAL_USER" \
    LOGNAME="$ORIGINAL_USER" \
    XDG_RUNTIME_DIR="/run/user/$(id -u "$ORIGINAL_USER")" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "$ORIGINAL_USER")/bus" \
    bash "$DIR/apply_desktop_theme.sh"
else
  bash "$DIR/apply_desktop_theme.sh"
fi

# Step 2: System bootloader, Plymouth splash, and GDM login page (runs with sudo)
echo ""
echo ">>> STEP 2: Applying macOS Boot Splash, GRUB & Login Screen..."
sudo bash "$DIR/setup_startup_and_login.sh"

echo ""
echo "========================================================================"
echo " COMPLETE MACOS TAHOE CUSTOMIZATION FINISHED SUCCESSFULLY!"
echo "========================================================================"
