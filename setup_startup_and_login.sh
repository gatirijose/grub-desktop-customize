#!/usr/bin/env bash
# ==============================================================================
# Maple Developer Splash, GRUB, and GDM Login Setup
# Developer Plymouth Splash, Maple GRUB Theme, and GDM Login Setup
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
  if [ -f /boot/grub/grub.cfg ]; then
    GRUB_CONFIG_PATH="/boot/grub/grub.cfg"
  elif [ -f /boot/grub.cfg ]; then
    GRUB_CONFIG_PATH="/boot/grub.cfg"
  else
    GRUB_CONFIG_PATH="/boot/grub/grub.cfg"
  fi
elif [ "${ID:-}" = "debian" ] || [ "${ID:-}" = "ubuntu" ] || [[ " ${ID_LIKE:-} " == *" debian "* ]]; then
  DISTRO_FAMILY="debian"
  GRUB_CONFIG_GENERATOR="update-grub"
  GRUB_CONFIG_PATH=""
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

ensure_kernel_args() {
  local file="$1"
  local mode="$2"
  [ -f "$file" ] || return 0
  [ -f "$file.bak" ] || cp "$file" "$file.bak"
  python3 - "$file" "$mode" <<'PY'
from pathlib import Path
import shlex
import sys

path = Path(sys.argv[1])
mode = sys.argv[2]
text = path.read_text()
args = ("quiet", "splash")

if mode == "cmdline":
    tokens = shlex.split(text)
    missing = [arg for arg in args if arg not in tokens]
    if missing:
        path.write_text(text.rstrip() + " " + " ".join(missing) + "\n")
else:
    lines = text.splitlines(keepends=True)
    changed = False
    for index, line in enumerate(lines):
        if line.lstrip().startswith("options "):
            tokens = shlex.split(line)
            missing = [arg for arg in args if arg not in tokens]
            if missing:
                lines[index] = line.rstrip("\n") + " " + " ".join(missing) + "\n"
                changed = True
    if changed:
        path.write_text("".join(lines))
PY
}

restore_systemd_boot_configs() {
  python3 - <<'PY'
from pathlib import Path
import shutil

backups = [Path('/etc/kernel/cmdline.bak')]
for directory in (Path('/boot/loader/entries'), Path('/efi/loader/entries'), Path('/boot/EFI/loader/entries')):
    if directory.is_dir():
        backups.extend(directory.glob('*.conf.bak'))
for backup in backups:
    if backup.is_file():
        original = Path(str(backup)[:-4])
        shutil.copy2(backup, original)
PY
}

# Check for restore option
if [ "$1" = "--restore" ]; then
  echo "==> Restoring system defaults from backups..."
  restore_systemd_boot_configs
  if [ -f /etc/mkinitcpio.conf.bak ]; then
    cp /etc/mkinitcpio.conf.bak /etc/mkinitcpio.conf
  fi
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
  if [ "$DISTRO_FAMILY" = "arch" ]; then
    mkinitcpio -P
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

if ! python3 -c 'import cairo' >/dev/null 2>&1; then
  if [ "$DISTRO_FAMILY" = "arch" ]; then
    echo "ERROR: Python Cairo support is missing. Install it with: sudo pacman -S python-cairo" >&2
  else
    echo "ERROR: Python Cairo support is missing. Install it with: sudo apt-get install python3-cairo" >&2
  fi
  exit 1
fi

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
  if [ -f /etc/mkinitcpio.conf ] && ! grep -Eq '^[[:space:]]*HOOKS=.*([[:space:]]|"|^)plymouth([[:space:]]|"|$)' /etc/mkinitcpio.conf; then
    [ ! -f /etc/mkinitcpio.conf.bak ] && cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bak
    python3 - <<'PY'
from pathlib import Path
import re

path = Path('/etc/mkinitcpio.conf')
text = path.read_text()
lines = text.splitlines()
for i, line in enumerate(lines):
    if re.match(r'^\s*HOOKS=', line) and not re.search(r'\bplymouth\b', line):
        if ' udev ' in f' {line} ':
          line = line.replace(' udev ', ' udev plymouth ', 1)
        elif 'systemd' in line and re.search(r'\bsystemd\b', line):
          line = re.sub(r'\bsystemd\b', 'systemd plymouth', line, count=1)
        elif 'udev ' in line:
          line = line.replace('udev ', 'udev plymouth ', 1)
        elif 'base ' in line:
            line = line.replace('base ', 'base plymouth ', 1)
        else:
            line = re.sub(r'(HOOKS=\(?")', r'\1plymouth ', line, count=1)
        lines[i] = line
        break
else:
    raise SystemExit('ERROR: Could not find the HOOKS line in /etc/mkinitcpio.conf.')
path.write_text('\n'.join(lines) + '\n')
PY
    echo "==> Added 'plymouth' to the Arch Linux mkinitcpio HOOKS array."
  elif [ ! -f /etc/mkinitcpio.conf ]; then
    echo "ERROR: /etc/mkinitcpio.conf was not found." >&2
    exit 1
  fi
fi

echo "============================================================"
echo " Starting System Startup UI & Login Page Customization"
echo "============================================================"

# 1. Backups (only once, never overwrite existing backup)
echo "==> [1/4] Creating backups of current configuration..."
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

# 2. Plymouth Startup UI (developer spinner and personalized title)
echo "==> [2/4] Installing the Maple developer Plymouth splash..."
mkdir -p /usr/share/plymouth/themes/obsidian-amber
cp -r "$THEME_PACK/plymouth/"* /usr/share/plymouth/themes/obsidian-amber/
chmod 644 /usr/share/plymouth/themes/obsidian-amber/*
chmod 755 /usr/share/plymouth/themes/obsidian-amber

# Keep the bundled name frames intact and select the developer spinner theme.
echo "==> Setting Plymouth default to obsidian-amber..."
plymouth-set-default-theme obsidian-amber -R

if [ "$DISTRO_FAMILY" = "arch" ]; then
  if command -v bootctl >/dev/null 2>&1 && bootctl status 2>/dev/null | grep -q 'Product: systemd-boot'; then
    echo "==> Adding Plymouth boot arguments for systemd-boot..."
    UPDATED_BOOT_CONFIG=0
    if [ -f /etc/kernel/cmdline ]; then
      ensure_kernel_args /etc/kernel/cmdline cmdline
      UPDATED_BOOT_CONFIG=1
    fi
    for entries_dir in /boot/loader/entries /efi/loader/entries /boot/EFI/loader/entries; do
      if [ -d "$entries_dir" ]; then
        while IFS= read -r -d '' entry; do
          if grep -q '^[[:space:]]*options ' "$entry"; then
            ensure_kernel_args "$entry" entry
            UPDATED_BOOT_CONFIG=1
          fi
        done < <(find "$entries_dir" -maxdepth 1 -type f -name '*.conf' -print0)
      fi
    done
    if [ "$UPDATED_BOOT_CONFIG" -eq 0 ]; then
      echo "ERROR: systemd-boot is active, but no /etc/kernel/cmdline or editable loader entry was found." >&2
      echo "Add 'quiet splash' to the command line used to build your UKI, then rerun mkinitcpio -P." >&2
      exit 1
    fi
  fi
  echo "==> Regenerating Arch Linux initramfs with mkinitcpio..."
  mkinitcpio -P
fi

# 4. GRUB Silent Boot with Maple Theme
echo "==> [3/4] Configuring GRUB with the Maple theme..."
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

# 5. GDM Login Page (solid maple background)
echo "==> [4/4] Installing GDM Login Screen (solid maple background)..."
cp "$THEME_PACK/gdm/gnome-shell-theme.gresource" /usr/share/gnome-shell/gnome-shell-theme.gresource
chmod 644 /usr/share/gnome-shell/gnome-shell-theme.gresource

echo "============================================================"
echo " ALL DONE! Everything installed correctly."
echo "============================================================"
echo ""
echo " GRUB:     Maple theme with centered boot menu"
echo " Plymouth: Maple developer spinner with personalized title"
echo " Login:    Solid maple background with themed controls"
echo " Desktop:  MacTahoe light/dark themes with orange accent"
echo ""
echo " Reboot to see all changes take effect."
echo "============================================================"
