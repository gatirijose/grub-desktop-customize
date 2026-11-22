#!/usr/bin/env bash
# ==============================================================================
# Obsidian Amber & macOS - Startup UI, Silent Boot & Login Page Setup
# Modifies GRUB, Plymouth (Silent Startup UI), and GDM (Login Screen)
# ==============================================================================
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_PACK="$DIR/theme_pack"

# Auto-elevate to root if not already root
if [ "$EUID" -ne 0 ]; then
  echo "==> Requesting administrator privileges to update bootloader and login UI..."
  exec sudo "$0" "$@"
fi

echo "============================================================"
echo " Starting System Startup UI & Login Page Customization"
echo "============================================================"

# Check for restore option
if [ "$1" = "--restore" ]; then
  echo "==> Restoring system defaults from backups..."
  if [ -f /etc/default/grub.bak ]; then
    cp /etc/default/grub.bak /etc/default/grub
    update-grub
  fi
  if [ -f /usr/share/gnome-shell/gnome-shell-theme.gresource.bak ]; then
    cp /usr/share/gnome-shell/gnome-shell-theme.gresource.bak /usr/share/gnome-shell/gnome-shell-theme.gresource
  fi
  plymouth-set-default-theme debian-theme -R 2>/dev/null || true
  echo "==> Restored factory settings."
  exit 0
fi

# 1. Backups
echo "==> [1/4] Creating backups of current configuration..."
[ ! -f /etc/default/grub.bak ] && cp /etc/default/grub /etc/default/grub.bak
[ ! -f /usr/share/gnome-shell/gnome-shell-theme.gresource.bak ] && cp /usr/share/gnome-shell/gnome-shell-theme.gresource /usr/share/gnome-shell/gnome-shell-theme.gresource.bak

# 2. Plymouth Startup UI
echo "==> [2/4] Installing Obsidian Amber Plymouth Theme (Silent Startup Animation)..."
mkdir -p /usr/share/plymouth/themes/obsidian-amber
cp -r "$THEME_PACK/plymouth/"* /usr/share/plymouth/themes/obsidian-amber/
chmod 644 /usr/share/plymouth/themes/obsidian-amber/*
chmod 755 /usr/share/plymouth/themes/obsidian-amber

# Set default Plymouth theme and update initramfs
echo "==> Updating initramfs with new splash theme..."
plymouth-set-default-theme obsidian-amber -R

# 3. GRUB Silent Boot & Theming
echo "==> [3/4] Configuring GRUB Silent Boot & Custom Wallpaper..."
mkdir -p /boot/grub/themes/obsidian-amber
cp -r "$THEME_PACK/grub/"* /boot/grub/themes/obsidian-amber/

# Update /etc/default/grub for completely silent boot and stylish background
python3 -c "
with open('/etc/default/grub', 'r') as f:
    lines = f.readlines()

new_lines = []
skip_keys = ['GRUB_CMDLINE_LINUX_DEFAULT', 'GRUB_THEME', 'GRUB_BACKGROUND', 'GRUB_GFXMODE', 'GRUB_TIMEOUT']
for line in lines:
    if any(line.strip().startswith(k + '=') for k in skip_keys):
        continue
    new_lines.append(line)

new_lines.append('\n# Obsidian Amber Silent Boot Configuration\n')
new_lines.append('GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash loglevel=3 rd.udev.log_priority=3 vt.global_cursor_default=0 systemd.show_status=auto\"\n')
new_lines.append('GRUB_THEME=\"/boot/grub/themes/obsidian-amber/theme.txt\"\n')
new_lines.append('GRUB_BACKGROUND=\"/boot/grub/themes/obsidian-amber/background.png\"\n')
new_lines.append('GRUB_GFXMODE=\"1920x1080,auto\"\n')
new_lines.append('GRUB_TIMEOUT=2\n')

with open('/etc/default/grub', 'w') as f:
    f.writelines(new_lines)
"

# Also update desktop-base active grub wallpaper if linked
if [ -d /usr/share/images/desktop-base ]; then
  cp "$THEME_PACK/wallpaper/wallpaper.png" /usr/share/images/desktop-base/desktop-grub.png 2>/dev/null || true
fi

echo "==> Regenerating GRUB bootloader configuration..."
update-grub

# 4. GDM Login Page Customization
echo "==> [4/4] Installing Custom GDM Login Screen..."
cp "$THEME_PACK/gdm/gnome-shell-theme.gresource" /usr/share/gnome-shell/gnome-shell-theme.gresource
chmod 644 /usr/share/gnome-shell/gnome-shell-theme.gresource

# Also place fallback wallpapers for desktop-base greeters
if [ -d /usr/share/desktop-base/active-theme/login ]; then
  magick "$THEME_PACK/wallpaper/wallpaper.png" -resize 1920x1080 /usr/share/desktop-base/active-theme/login/background.svg 2>/dev/null || true
fi

echo "============================================================"
echo " ALL DONE! Startup UI, Silent Boot & Login Page Installed!"
echo "============================================================"
echo "Summary of applied changes:"
echo " 1. Silent boot enabled (no text logging during boot)"
echo " 2. Plymouth animated golden glowing boot splash active"
echo " 3. GRUB theme with native resolution and custom background active"
echo " 4. GDM Login Page styled with Obsidian Amber wallpaper and frosted glass dialog"
echo "============================================================"
