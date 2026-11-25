# macOS Tahoe Desktop & System UI Suite
### Complete macOS Tahoe Theming for Debian or Arch Linux / GNOME (GTK4/Nautilus, GDM, GRUB & Plymouth)

A complete, automated customization suite for **Debian/Ubuntu and Arch Linux with GNOME**, implementing the macOS Tahoe look and feel.

Theme and icon foundations:
- **MacTahoe GTK Theme**: [vinceliuice/MacTahoe-gtk-theme](https://github.com/vinceliuice/MacTahoe-gtk-theme)
- **MacTahoe Icon Theme**: [vinceliuice/MacTahoe-icon-theme](https://github.com/vinceliuice/MacTahoe-icon-theme)

---

## 🌟 Visual Architecture

| Component | Theme & Style | Description |
| :--- | :--- | :--- |
| **Main UI / GTK** | MacTahoe-Dark-orange / MacTahoe-Light-orange | Light and dark MacTahoe desktop themes with orange accents |
| **Accent Color** | Orange | macOS orange accent across toggles, sliders, and highlights |
| **File Manager (Nautilus)** | Libadwaita MacTahoe GTK4 | Full macOS styling applied via `~/.config/gtk-4.0/` with orange highlights |
| **Icons & Cursors** | MacTahoe-orange-dark / MacTahoe-cursors | macOS Tahoe orange folder icons and high-DPI cursors |
| **Login / Lock Screen (GDM)** | Maple red | Solid maple background and themed GNOME controls |
| **GRUB Bootloader** | Obsidian Amber | Maple-red wallpaper with a centered boot menu |
| **Power On (Plymouth)** | Maple Developer Splash | Animated developer spinner and personalized name badge |

---

## 🚀 Installation & Usage

### Arch Linux prerequisites
Install and configure GNOME/GDM, GRUB, Plymouth, and the utilities used by the scripts before running the installer:
```bash
sudo pacman -S --needed git grub plymouth mkinitcpio python imagemagick dconf gnome-shell gdm
```
The setup script adds `plymouth` to the mkinitcpio hooks and rebuilds initramfs. On systemd-boot installations it also adds `quiet splash` to `/etc/kernel/cmdline` and editable loader entries before rebuilding. If your UKI is built from a different command-line source, configure that source to include `splash` as well. GRUB installations receive the same boot arguments through `/etc/default/grub`.

### 1. Apply Desktop Environment & Nautilus UI (User-Level, No Root Needed)
```bash
./apply_desktop_theme.sh
```
*Installs and selects both MacTahoe light and dark orange themes, orange icons and accents, and links GTK4 styles to `~/.config/gtk-4.0/`.*

### 2. Apply macOS Boot Splash, GRUB & Login Screen (Requires Sudo)
```bash
sudo ./setup_startup_and_login.sh
```
*Installs the personalized developer spinner Plymouth splash, configures GRUB and supported systemd-boot command lines, and applies a solid maple GDM background.*

### 3. Master One-Shot Installer (Runs Both Steps)
```bash
./install_all.sh
```

### 4. Restore Previous Settings
If you ever want to revert GRUB, Plymouth, systemd-boot command-line files, and GDM to their saved prior settings:
```bash
sudo ./setup_startup_and_login.sh --restore
```
