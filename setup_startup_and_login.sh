#!/usr/bin/env bash
# ==============================================================================
# Obsidian Amber & Maple Red - Startup UI, Silent Boot & Login Page Setup
# QLED-Optimized: Maple Red Power Splash & Developer Terminal Animation
# ==============================================================================
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_PACK="$DIR/theme_pack"
PLYMOUTH_THEME_BACKUP="/etc/default/plymouth-theme.bak"

# Auto-elevate to root if not already root
if [ "$EUID" -ne 0 ]; then
  echo "==> Requesting administrator privileges to update bootloader and login UI..."
  exec sudo "$0" "$@"
fi

if [ ! -r /etc/os-release ]; then
  echo "ERROR: Cannot identify this Linux distribution (/etc/os-release is missing)." >&2
  exit 1
fi
# shellcheck source=/dev/null
. /etc/os-release

if [ "${ID:-}" = "arch" ] || [[ " ${ID_LIKE:-} " == *" arch "* ]]; then
  DISTRO_FAMILY="arch"
  GRUB_CONFIG_GENERATOR="grub-mkconfig"
  GRUB_CONFIG_PATH="/boot/grub/grub.cfg"
elif [ "${ID:-}" = "debian" ] || [ "${ID:-}" = "ubuntu" ] || [[ " ${ID_LIKE:-} " == *" debian "* ]]; then
  DISTRO_FAMILY="debian"
  GRUB_CONFIG_GENERATOR="update-grub"
else
  echo "ERROR: This script supports Arch Linux and Debian/Ubuntu systems only." >&2
  echo "Detected distribution: ${PRETTY_NAME:-${ID:-unknown}}" >&2
  exit 1
fi

regenerate_grub_config() {
  if [ "$DISTRO_FAMILY" = "arch" ]; then
    "$GRUB_CONFIG_GENERATOR" -o "$GRUB_CONFIG_PATH"
  else
    "$GRUB_CONFIG_GENERATOR"
  fi
}

# Check for restore option
if [ "$1" = "--restore" ]; then
  echo "==> Restoring system defaults from backups..."
  if [ -f /etc/default/grub.bak ]; then
    cp /etc/default/grub.bak /etc/default/grub
    regenerate_grub_config
  fi
  if [ -f /usr/share/gnome-shell/gnome-shell-theme.gresource.bak ]; then
    cp /usr/share/gnome-shell/gnome-shell-theme.gresource.bak /usr/share/gnome-shell/gnome-shell-theme.gresource
  fi
  if [ -s "$PLYMOUTH_THEME_BACKUP" ]; then
    plymouth-set-default-theme "$(cat "$PLYMOUTH_THEME_BACKUP")" -R
  else
    echo "NOTE: No saved Plymouth theme was found; leaving the current theme unchanged."
  fi
  echo "==> Restored factory settings."
  exit 0
fi

for command_name in python3 plymouth-set-default-theme "$GRUB_CONFIG_GENERATOR"; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "ERROR: Required command '$command_name' is not installed." >&2
    exit 1
  fi
done

if [ ! -f /etc/default/grub ] || [ ! -f /usr/share/gnome-shell/gnome-shell-theme.gresource ]; then
  echo "ERROR: GRUB and GNOME Shell system files were not found." >&2
  echo "Install and configure GRUB and GNOME Shell before running this script." >&2
  exit 1
fi

if [ "$DISTRO_FAMILY" = "arch" ]; then
  if ! command -v mkinitcpio >/dev/null 2>&1; then
    echo "ERROR: Required command 'mkinitcpio' is not installed." >&2
    exit 1
  fi
  if [ ! -f /etc/mkinitcpio.conf ] || ! grep -Eq '^[[:space:]]*HOOKS=.*([[:space:]]|")plymouth([[:space:]]|")' /etc/mkinitcpio.conf; then
    echo "ERROR: Arch Linux needs the 'plymouth' hook in /etc/mkinitcpio.conf." >&2
    echo "Add it to HOOKS (after udev), then run this script again." >&2
    exit 1
  fi
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
if [ ! -f "$PLYMOUTH_THEME_BACKUP" ]; then
  ORIGINAL_PLYMOUTH_THEME="$(plymouth-set-default-theme)"
  if [ -n "$ORIGINAL_PLYMOUTH_THEME" ]; then
    printf '%s\n' "$ORIGINAL_PLYMOUTH_THEME" > "$PLYMOUTH_THEME_BACKUP"
  else
    echo "ERROR: Could not determine the current Plymouth theme; refusing to continue." >&2
    exit 1
  fi
fi

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
regenerate_grub_config

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
