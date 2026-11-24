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

# 1. Backups (only once, never overwrite existing backup)
echo "==> [1/5] Creating backups of current configuration..."
[ ! -f /etc/default/grub.bak ] && cp /etc/default/grub /etc/default/grub.bak
[ ! -f /usr/share/gnome-shell/gnome-shell-theme.gresource.bak ] && cp /usr/share/gnome-shell/gnome-shell-theme.gresource /usr/share/gnome-shell/gnome-shell-theme.gresource.bak

# 2. Generate Developer Animation Frames
echo "==> [2/5] Rendering animated Developer Title badge with blinking cursor..."
python3 "$THEME_PACK/plymouth/generate_title.py" "$TITLE" "$THEME_PACK/plymouth"

# 3. Plymouth Startup UI (Maple Red maroon animation on black)
echo "==> [3/5] Installing Maple Red Plymouth Theme (Developer Core + Update Handler)..."
mkdir -p /usr/share/plymouth/themes/obsidian-amber
cp -r "$THEME_PACK/plymouth/"* /usr/share/plymouth/themes/obsidian-amber/
chmod 644 /usr/share/plymouth/themes/obsidian-amber/*
chmod 755 /usr/share/plymouth/themes/obsidian-amber

# Force Plymouth to our theme (overriding any other theme that was set)
echo "==> Setting Plymouth default to obsidian-amber..."
plymouth-set-default-theme obsidian-amber -R

# 4. GRUB Silent Boot with Maple Red Gradient Wallpaper
echo "==> [4/5] Configuring GRUB with Maple Red Gradient Wallpaper..."
mkdir -p /boot/grub/themes/obsidian-amber
cp -r "$THEME_PACK/grub/"* /boot/grub/themes/obsidian-amber/

# Clean /etc/default/grub completely: remove ALL previous theme entries and duplicates
python3 -c "
with open('/etc/default/grub', 'r') as f:
    lines = f.readlines()

new_lines = []
skip_keys = ['GRUB_CMDLINE_LINUX_DEFAULT', 'GRUB_THEME', 'GRUB_BACKGROUND', 'GRUB_GFXMODE', 'GRUB_TIMEOUT']
skip_comments = ['Obsidian Amber', 'Maple Red', 'macOS Tahoe']
for line in lines:
    stripped = line.strip()
    # Skip our previous config lines and comments
    if any(stripped.startswith(k + '=') for k in skip_keys):
        continue
    if any(c in stripped for c in skip_comments):
        continue
    if stripped == '':
        # Only keep one blank line at a time
        if new_lines and new_lines[-1].strip() == '':
            continue
    new_lines.append(line)

# Remove trailing blank lines
while new_lines and new_lines[-1].strip() == '':
    new_lines.pop()

new_lines.append('\n\n# Obsidian Amber & Maple Red Silent Boot\n')
new_lines.append('GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash loglevel=3 rd.udev.log_priority=3 vt.global_cursor_default=0 systemd.show_status=auto\"\n')
new_lines.append('GRUB_THEME=\"/boot/grub/themes/obsidian-amber/theme.txt\"\n')
new_lines.append('GRUB_BACKGROUND=\"/boot/grub/themes/obsidian-amber/background.png\"\n')
new_lines.append('GRUB_GFXMODE=\"1920x1080,auto\"\n')
new_lines.append('GRUB_TIMEOUT=2\n')

with open('/etc/default/grub', 'w') as f:
    f.writelines(new_lines)
print('Cleaned and wrote /etc/default/grub')
"

echo "==> Regenerating GRUB bootloader configuration..."
update-grub

# 5. GDM Login Page (Pinterest wallpaper + Maroon accent)
echo "==> [5/5] Installing GDM Login Screen (Maroon accent, Pinterest wallpaper)..."
cp "$THEME_PACK/gdm/gnome-shell-theme.gresource" /usr/share/gnome-shell/gnome-shell-theme.gresource
chmod 644 /usr/share/gnome-shell/gnome-shell-theme.gresource

echo "============================================================"
echo " ALL DONE! Everything installed correctly."
echo "============================================================"
echo ""
echo " GRUB:     Maple Red gradient wallpaper, clean theme (no missing = error)"
echo " Plymouth: Maple Red developer animation with '$TITLE'"
echo "           Update text handler enabled (SetUpdateStatusFunction)"
echo " Login:    Pinterest wallpaper + Maroon (#9b111e) accent buttons"
echo " Desktop:  Orange accent preserved (MacTahoe-Dark-orange GTK theme)"
echo ""
echo " Reboot to see all changes take effect."
echo "============================================================"
