#!/usr/bin/env bash
# ==============================================================================
# macOS Tahoe Desktop & UI Theme Applier
# Applies macOS Tahoe GTK, Libadwaita (Nautilus), Icons, Cursors, Dock & Shortcuts
# Uses installed Vinceliuice MacTahoe themes (clones only if not present)
# ==============================================================================
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_PACK="$DIR/theme_pack"

echo "========================================================================"
echo " Applying macOS Tahoe Interface & Nautilus UI"
echo "========================================================================"

# ------------------------------------------------------------------------------
# 1. Verify / Install MacTahoe GTK Theme (Orange variant, standard/normal colors)
# ------------------------------------------------------------------------------
GTK_THEME_NAME="MacTahoe-Dark-orange"
GTK_THEME_DIR=""
for candidate in "/usr/share/themes/$GTK_THEME_NAME" "$HOME/.themes/$GTK_THEME_NAME" "$HOME/.local/share/themes/$GTK_THEME_NAME" "$THEME_PACK/themes/$GTK_THEME_NAME"; do
  if [ -d "$candidate" ]; then
    GTK_THEME_DIR="$candidate"
    break
  fi
done

if [ -n "$GTK_THEME_DIR" ]; then
  echo "==> [1/6] Found included MacTahoe GTK theme at: $GTK_THEME_DIR (skipping clone)"
else
  echo "==> [1/6] MacTahoe GTK theme not included locally. Cloning repository..."
  CLONE_DIR=$(mktemp -d)
  git clone --depth=1 https://github.com/vinceliuice/MacTahoe-gtk-theme.git "$CLONE_DIR"
  mkdir -p "$HOME/.themes"
  bash "$CLONE_DIR/install.sh" -d "$HOME/.themes" -c dark -t orange
  rm -rf "$CLONE_DIR"
  GTK_THEME_DIR="$HOME/.themes/$GTK_THEME_NAME"
fi

# ------------------------------------------------------------------------------
# 2. Verify / Install MacTahoe Icon Theme (macOS Tahoe Orange)
# ------------------------------------------------------------------------------
ICON_THEME_NAME="MacTahoe-orange-dark"
ICON_THEME_DIR=""
for candidate in "/usr/share/icons/$ICON_THEME_NAME" "$HOME/.icons/$ICON_THEME_NAME" "$HOME/.local/share/icons/$ICON_THEME_NAME" "$THEME_PACK/icons/$ICON_THEME_NAME"; do
  if [ -d "$candidate" ]; then
    ICON_THEME_DIR="$candidate"
    break
  fi
done

if [ -n "$ICON_THEME_DIR" ]; then
  echo "==> [2/6] Found included MacTahoe icon theme at: $ICON_THEME_DIR (skipping clone)"
else
  echo "==> [2/6] MacTahoe icon theme not included locally. Cloning repository..."
  CLONE_DIR=$(mktemp -d)
  git clone --depth=1 https://github.com/vinceliuice/MacTahoe-icon-theme.git "$CLONE_DIR"
  mkdir -p "$HOME/.icons"
  bash "$CLONE_DIR/install.sh" -d "$HOME/.icons" -a
  rm -rf "$CLONE_DIR"
fi

# ------------------------------------------------------------------------------
# 3. Fix Nautilus & GTK4 / Libadwaita Theming (Pasted image.png Fix)
# In GNOME 45-48, Libadwaita apps ignore gtk-theme unless ~/.config/gtk-4.0 has the theme
# ------------------------------------------------------------------------------
echo "==> [3/6] Applying macOS Tahoe styling to Nautilus & Libadwaita applications..."
mkdir -p "$HOME/.config/gtk-4.0"

GTK4_SRC=""
if [ -d "$GTK_THEME_DIR/gtk-4.0" ]; then
  GTK4_SRC="$GTK_THEME_DIR/gtk-4.0"
elif [ -d "/usr/share/themes/$GTK_THEME_NAME/gtk-4.0" ]; then
  GTK4_SRC="/usr/share/themes/$GTK_THEME_NAME/gtk-4.0"
fi

if [ -n "$GTK4_SRC" ]; then
  cp -f "$GTK4_SRC/gtk.css" "$HOME/.config/gtk-4.0/gtk.css" 2>/dev/null || true
  cp -f "$GTK4_SRC/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css" 2>/dev/null || true
  if [ -d "$GTK4_SRC/assets" ]; then
    rm -rf "$HOME/.config/gtk-4.0/assets"
    ln -sfn "$GTK4_SRC/assets" "$HOME/.config/gtk-4.0/assets"
  fi
  if [ -d "$GTK4_SRC/windows-assets" ]; then
    rm -rf "$HOME/.config/gtk-4.0/windows-assets"
    ln -sfn "$GTK4_SRC/windows-assets" "$HOME/.config/gtk-4.0/windows-assets"
  fi
  echo "    -> Nautilus and GTK4 config linked successfully to $GTK4_SRC"
fi

# ------------------------------------------------------------------------------
# 4. Activate macOS Tahoe Themes in GNOME Settings (Orange accents & Tahoe icons)
# ------------------------------------------------------------------------------
echo "==> [4/6] Setting GNOME interface to $GTK_THEME_NAME, macOS Orange Icons & Cursors..."
dconf write /org/gnome/desktop/interface/gtk-theme "'$GTK_THEME_NAME'"
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME_NAME" 2>/dev/null || true

dconf write /org/gnome/desktop/interface/accent-color "'orange'"
gsettings set org.gnome.desktop.interface accent-color 'orange' 2>/dev/null || true

dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true

dconf write /org/gnome/desktop/interface/icon-theme "'$ICON_THEME_NAME'"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME_NAME" 2>/dev/null || true

dconf write /org/gnome/desktop/interface/cursor-theme "'MacTahoe-cursors'"
gsettings set org.gnome.desktop.interface cursor-theme 'MacTahoe-cursors' 2>/dev/null || true

# Enable user-theme extension if available and set Shell theme
if gnome-extensions list 2>/dev/null | grep -q "user-theme@gnome-shell-extensions.gcampax.github.com"; then
  gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null || true
fi
dconf write /org/gnome/shell/extensions/user-theme/name "'$GTK_THEME_NAME'" 2>/dev/null || true
gsettings set org.gnome.shell.extensions.user-theme name "$GTK_THEME_NAME" 2>/dev/null || true

# macOS Traffic Lights on the top-left
dconf write /org/gnome/desktop/wm/preferences/button-layout "'close,minimize,maximize:appmenu'"

# ------------------------------------------------------------------------------
# 5. Apply Wallpaper (Hero Banner & Desktop Background)
# ------------------------------------------------------------------------------
echo "==> [5/6] Setting desktop wallpaper and lock screen..."
mkdir -p "$HOME/.local/share/backgrounds"
WALLPAPER_SRC="$THEME_PACK/wallpaper/hero_banner.png"

if [ ! -f "$WALLPAPER_SRC" ] && [ -f "$DIR/Hero_Banner_MLM.avif" ]; then
  magick "$DIR/Hero_Banner_MLM.avif" -resize 1920x1080^ -gravity center -extent 1920x1080 -depth 8 -alpha off "$WALLPAPER_SRC"
fi

if [ -f "$WALLPAPER_SRC" ]; then
  cp -f "$WALLPAPER_SRC" "$HOME/.local/share/backgrounds/mactahoe_hero.png"
  dconf write /org/gnome/desktop/background/picture-uri "'file://$HOME/.local/share/backgrounds/mactahoe_hero.png'"
  dconf write /org/gnome/desktop/background/picture-uri-dark "'file://$HOME/.local/share/backgrounds/mactahoe_hero.png'"
  dconf write /org/gnome/desktop/background/picture-options "'zoom'"
  dconf write /org/gnome/desktop/screensaver/picture-uri "'file://$HOME/.local/share/backgrounds/mactahoe_hero.png'"
fi

# ------------------------------------------------------------------------------
# 6. macOS Floating Dock (Dash to Dock) & Frosted Blur
# ------------------------------------------------------------------------------
echo "==> [6/6] Configuring macOS Floating Dock & Blur..."
dconf write /org/gnome/shell/extensions/dash-to-dock/dock-position "'BOTTOM'"
dconf write /org/gnome/shell/extensions/dash-to-dock/extend-height "false"
dconf write /org/gnome/shell/extensions/dash-to-dock/custom-theme-shrink "true"
dconf write /org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size "52"
dconf write /org/gnome/shell/extensions/dash-to-dock/background-opacity "0.25"
dconf write /org/gnome/shell/extensions/dash-to-dock/click-action "'focus-minimize-or-appspread'"
dconf write /org/gnome/shell/extensions/dash-to-dock/autohide "true"

# Productivity shortcuts (Super+E -> Nautilus, Super+D -> Desktop, etc.)
dconf write /org/gnome/settings-daemon/plugins/media-keys/home "['<Super>e']"
dconf write /org/gnome/desktop/wm/keybindings/show-desktop "['<Super>d']"
dconf write /org/gnome/settings-daemon/plugins/media-keys/screensaver "['<Super>l']"
dconf write /org/gnome/settings-daemon/plugins/media-keys/control-center "['<Super>i']"
dconf write /org/gnome/mutter/keybindings/toggle-tiled-left "['<Super>Left']"
dconf write /org/gnome/mutter/keybindings/toggle-tiled-right "['<Super>Right']"
dconf write /org/gnome/desktop/wm/keybindings/maximize "['<Super>Up']"
dconf write /org/gnome/desktop/wm/keybindings/unmaximize "['<Super>Down']"
dconf write /org/gnome/desktop/wm/keybindings/switch-windows "['<Alt>Tab']"
dconf write /org/gnome/desktop/wm/keybindings/close "['<Alt>F4']"
dconf write /org/gnome/shell/keybindings/show-screenshot-ui "['Print', '<Super><Shift>s']"

echo ""
echo "========================================================================"
echo " SUCCESS: macOS Tahoe Theme & Nautilus UI Applied Perfectly!"
echo " Restart Nautilus ('nautilus -q') to see the macOS look immediately."
echo "========================================================================"
