#!/usr/bin/env bash
# ==============================================================================
# Obsidian Amber & macOS Fluid Glass - Desktop Theme Applier
# Applies all User-Level Desktop Customizations (No Root / No Git Clone Needed)
# ==============================================================================
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_PACK="$DIR/theme_pack"

echo "==> [1/5] Applying Wallpaper & Screen Lock Background..."
mkdir -p "$HOME/.local/share/backgrounds"
cp "$THEME_PACK/wallpaper/wallpaper.png" "$HOME/.local/share/backgrounds/obsidian_amber.png"
cp "$THEME_PACK/wallpaper/wallpaper.png" "$HOME/.config/background.png"

dconf write /org/gnome/desktop/background/picture-uri "'file://$HOME/.local/share/backgrounds/obsidian_amber.png'"
dconf write /org/gnome/desktop/background/picture-uri-dark "'file://$HOME/.local/share/backgrounds/obsidian_amber.png'"
dconf write /org/gnome/desktop/background/picture-options "'zoom'"
dconf write /org/gnome/desktop/screensaver/picture-uri "'file://$HOME/.local/share/backgrounds/obsidian_amber.png'"

echo "==> [2/5] Configuring Windows Productivity Shortcuts..."
# Super + E: File Explorer
dconf write /org/gnome/settings-daemon/plugins/media-keys/home "['<Super>e']"
# Super + D: Show / Hide Desktop
dconf write /org/gnome/desktop/wm/keybindings/show-desktop "['<Super>d']"
# Super + L: Lock Screen
dconf write /org/gnome/settings-daemon/plugins/media-keys/screensaver "['<Super>l']"
# Super + I: Windows Settings
dconf write /org/gnome/settings-daemon/plugins/media-keys/control-center "['<Super>i']"
# Super + Left / Right: Snap Window to Half
dconf write /org/gnome/mutter/keybindings/toggle-tiled-left "['<Super>Left']"
dconf write /org/gnome/mutter/keybindings/toggle-tiled-right "['<Super>Right']"
# Super + Up / Down: Maximize / Restore
dconf write /org/gnome/desktop/wm/keybindings/maximize "['<Super>Up']"
dconf write /org/gnome/desktop/wm/keybindings/unmaximize "['<Super>Down']"
# Alt + Tab: Windows Switcher
dconf write /org/gnome/desktop/wm/keybindings/switch-windows "['<Alt>Tab']"
dconf write /org/gnome/desktop/wm/keybindings/switch-windows-backward "['<Alt><Shift>Tab']"
# Alt + F4: Close Window
dconf write /org/gnome/desktop/wm/keybindings/close "['<Alt>F4']"
# Super + Shift + S: Snipping Tool / Interactive Screenshot
dconf write /org/gnome/shell/keybindings/show-screenshot-ui "['Print', '<Super><Shift>s']"
# Super + V: Clipboard Manager
dconf write /org/gnome/shell/extensions/clipboard-indicator/toggle-menu "['<Super>v']"
# Ctrl + Shift + Esc: Task Manager
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/']"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/name "'Task Manager'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/command "'gnome-system-monitor'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/binding "'<Primary><Shift>Escape'"

echo "==> [3/5] Configuring ArcMenu (Windows 11 Start Menu with macOS Glass)..."
# Super key alone opens ArcMenu
dconf write /org/gnome/shell/extensions/arcmenu/arcmenu-hotkey "['Super_L']"
dconf write /org/gnome/shell/extensions/arcmenu/arcmenu-hotkey-overlay-key-enabled "true"
# Windows 11 Menu Layout centered horizontally above dock
dconf write /org/gnome/shell/extensions/arcmenu/menu-layout "'11'"
dconf write /org/gnome/shell/extensions/arcmenu/force-menu-location "'BottomCentered'"
# macOS Translucent Glass Styling matching wallpaper palette
dconf write /org/gnome/shell/extensions/arcmenu/override-menu-theme "true"
dconf write /org/gnome/shell/extensions/arcmenu/menu-background-color "'rgba(18, 12, 8, 0.82)'"
dconf write /org/gnome/shell/extensions/arcmenu/menu-border-color "'rgba(215, 200, 151, 0.28)'"
dconf write /org/gnome/shell/extensions/arcmenu/menu-border-radius "22"
dconf write /org/gnome/shell/extensions/arcmenu/menu-foreground-color "'rgb(245, 238, 230)'"
dconf write /org/gnome/shell/extensions/arcmenu/menu-separator-color "'rgba(255, 255, 255, 0.08)'"
dconf write /org/gnome/shell/extensions/arcmenu/menu-item-hover-bg-color "'rgba(198, 124, 13, 0.28)'"
dconf write /org/gnome/shell/extensions/arcmenu/menu-item-hover-fg-color "'rgb(255, 255, 255)'"
dconf write /org/gnome/shell/extensions/arcmenu/menu-item-active-bg-color "'rgb(198, 124, 13)'"
dconf write /org/gnome/shell/extensions/arcmenu/menu-item-active-fg-color "'rgb(255, 255, 255)'"
dconf write /org/gnome/shell/extensions/arcmenu/search-entry-border-radius "(true, 22)"

echo "==> [4/5] Configuring macOS Dock (Dash to Dock) & Frosted Blur..."
dconf write /org/gnome/shell/extensions/dash-to-dock/dock-position "'BOTTOM'"
dconf write /org/gnome/shell/extensions/dash-to-dock/custom-theme-shrink "true"
dconf write /org/gnome/shell/extensions/dash-to-dock/extend-height "false"
dconf write /org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size "46"
dconf write /org/gnome/shell/extensions/dash-to-dock/background-opacity "0.32"
dconf write /org/gnome/shell/extensions/dash-to-dock/custom-theme-customize-running-dots "true"
dconf write /org/gnome/shell/extensions/dash-to-dock/custom-theme-running-dots-color "'#e5b869'"
dconf write /org/gnome/shell/extensions/dash-to-dock/click-action "'focus-minimize-or-appspread'"
dconf write /org/gnome/shell/extensions/dash-to-dock/autohide "true"

# Blur-my-shell
dconf write /org/gnome/shell/extensions/blur-my-shell/dash-to-dock/pipeline "'pipeline_liquid_glass'"
dconf write /org/gnome/shell/extensions/blur-my-shell/dash-to-dock/blur "true"
dconf write /org/gnome/shell/extensions/blur-my-shell/panel/pipeline "'pipeline_liquid_glass'"
dconf write /org/gnome/shell/extensions/blur-my-shell/panel/blur "true"
dconf write /org/gnome/shell/extensions/blur-my-shell/panel/corner-radius "14"
dconf write /org/gnome/shell/extensions/blur-my-shell/popup/pipeline "'pipeline_vapor_glass'"
dconf write /org/gnome/shell/extensions/blur-my-shell/popup/blur "true"

# macOS Traffic Lights on Left
dconf write /org/gnome/desktop/wm/preferences/button-layout "'close,minimize,maximize:appmenu'"

echo "==> [5/5] Activating Custom Obsidian Amber GTK & Shell Themes..."
dconf write /org/gnome/shell/extensions/user-theme/name "'ObsidianAmber-macOS'"

echo "==> SUCCESS: Desktop UI, shortcuts, and themes applied perfectly!"
