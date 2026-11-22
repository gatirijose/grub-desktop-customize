#!/usr/bin/env bash
# ==============================================================================
# Obsidian Amber & Maple Red - Startup UI, Silent Boot & Login Page Setup
# QLED-Optimized: Maple Red Power Splash & Developer Terminal Animation
# ==============================================================================
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_PACK="$DIR/theme_pack"

# Auto-elevate to root if not already root
if [ "$EUID" -ne 0 ]; then
  echo "==> Requesting administrator privileges to update bootloader and login UI..."
  exec sudo "$0" "$@"
fi

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

# Parse Developer Title parameter
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

if [ -z "$TITLE" ]; then
  if [ -t 0 ]; then
    echo ""
    echo "============================================================"
    echo "  SOFTWARE DEVELOPER SPLASH CUSTOMIZATION"
    echo "============================================================"
    read -p "Enter Developer Title for power-on splash [Default: JOSEPH // SOFTWARE DEVELOPER]: " INPUT_TITLE
    TITLE="${INPUT_TITLE:-JOSEPH // SOFTWARE DEVELOPER}"
  else
    TITLE="JOSEPH // SOFTWARE DEVELOPER"
  fi
fi

echo "============================================================"
echo " Starting System Startup UI & Login Page Customization"
echo " Developer Title: $TITLE"
echo "============================================================"

# 1. Backups
echo "==> [1/5] Creating backups of current configuration..."
[ ! -f /etc/default/grub.bak ] && cp /etc/default/grub /etc/default/grub.bak
[ ! -f /usr/share/gnome-shell/gnome-shell-theme.gresource.bak ] && cp /usr/share/gnome-shell/gnome-shell-theme.gresource /usr/share/gnome-shell/gnome-shell-theme.gresource.bak

# 2. Generate Developer Animation Frames
echo "==> [2/5] Rendering animated Developer Title badge with blinking cursor..."
python3 "$THEME_PACK/plymouth/generate_title.py" "$TITLE" "$THEME_PACK/plymouth"

# 3. Plymouth Startup UI
echo "==> [3/5] Installing QLED Maple Red Plymouth Theme (Developer Core + Offline Updates)..."
mkdir -p /usr/share/plymouth/themes/obsidian-amber
cp -r "$THEME_PACK/plymouth/"* /usr/share/plymouth/themes/obsidian-amber/
chmod 644 /usr/share/plymouth/themes/obsidian-amber/*
chmod 755 /usr/share/plymouth/themes/obsidian-amber

# Set default Plymouth theme and update initramfs
echo "==> Updating initramfs with new splash theme..."
plymouth-set-default-theme obsidian-amber -R

# 4. GRUB Silent Boot & Theming (Maple Red to Black Gradient)
echo "==> [4/5] Configuring GRUB with Maple Red Gradient Wallpaper..."
mkdir -p /boot/grub/themes/obsidian-amber
cp -r "$THEME_PACK/grub/"* /boot/grub/themes/obsidian-amber/

python3 -c "
with open('/etc/default/grub', 'r') as f:
    lines = f.readlines()

new_lines = []
skip_keys = ['GRUB_CMDLINE_LINUX_DEFAULT', 'GRUB_THEME', 'GRUB_BACKGROUND', 'GRUB_GFXMODE', 'GRUB_TIMEOUT']
for line in lines:
    if any(line.strip().startswith(k + '=') for k in skip_keys):
        continue
    new_lines.append(line)

new_lines.append('\n# Obsidian Amber & Maple Red Silent Boot Configuration\n')
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
  cp "$THEME_PACK/grub/background.png" /usr/share/images/desktop-base/desktop-grub.png 2>/dev/null || true
fi

echo "==> Regenerating GRUB bootloader configuration..."
update-grub

# 5. GDM Login Page Customization (Pinterest Wallpaper + Crimson Ruby Accent)
echo "==> [5/5] Installing Custom GDM Login Screen (Pinterest Wallpaper & Crimson Ruby Accent)..."
cp "$THEME_PACK/gdm/gnome-shell-theme.gresource" /usr/share/gnome-shell/gnome-shell-theme.gresource
chmod 644 /usr/share/gnome-shell/gnome-shell-theme.gresource

# Also place fallback wallpapers for desktop-base greeters
if [ -d /usr/share/desktop-base/active-theme/login ]; then
  magick "$THEME_PACK/wallpaper/login_background.png" -resize 1920x1080 /usr/share/desktop-base/active-theme/login/background.svg 2>/dev/null || true
fi

echo "============================================================"
echo " ALL DONE! Startup UI, Developer Splash & Login Installed!"
echo "============================================================"
echo "Summary of applied changes:"
echo " 1. GRUB Menu Wallpaper: Maple Red to Pure Black Gradient active"
echo " 2. Power-on Animation: 180x180 Developer Core (>_ terminal prompt + HUD ring)"
echo " 3. Developer Title Badge: \"$TITLE\" with animated blinking cursor"
echo " 4. Offline Update Progress: System messages and update status visible"
echo " 5. GDM Login Screen: Pinterest wallpaper + matching Crimson Ruby accent"
echo "============================================================"
