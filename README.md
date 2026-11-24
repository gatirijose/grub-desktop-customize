# macOS Tahoe Desktop & System UI Suite
### Complete macOS Tahoe Theming for Debian / GNOME (GTK4/Nautilus, GDM, GRUB & Plymouth)

A complete, automated customization suite designed for **Debian / GNOME** implementing the authentic macOS Tahoe look and feel.

Theme and icon foundations:
- **MacTahoe GTK Theme**: [vinceliuice/MacTahoe-gtk-theme](https://github.com/vinceliuice/MacTahoe-gtk-theme)
- **MacTahoe Icon Theme**: [vinceliuice/MacTahoe-icon-theme](https://github.com/vinceliuice/MacTahoe-icon-theme)

---

## 🌟 Visual Architecture

| Component | Theme & Style | Description |
| :--- | :--- | :--- |
| **Main UI / GTK** | MacTahoe-Dark-orange | Authentic macOS dark styling with orange accents & traffic lights on top left |
| **Accent Color** | Orange | macOS orange accent across toggles, sliders, and highlights |
| **File Manager (Nautilus)** | Libadwaita MacTahoe GTK4 | Full macOS styling applied via `~/.config/gtk-4.0/` with orange highlights |
| **Icons & Cursors** | MacTahoe-orange-dark / MacTahoe-cursors | macOS Tahoe orange folder icons and high-DPI cursors |
| **Login Screen (GDM)** | MacTahoe macOS Frosted Glass | macOS login card with blurred hero background |
| **GRUB Bootloader** | macOS Tahoe Vinceliuice Layout | Centered Apple logo, macOS selection capsule, OS icons & 8-bit Hero Wallpaper |
| **Power On (Plymouth)** | Silent macOS Boot Splash | Pure black background, crisp Apple logo and smooth progress bar |

---

## 🚀 Installation & Usage

### 1. Apply Desktop Environment & Nautilus UI (User-Level, No Root Needed)
```bash
./apply_desktop_theme.sh
```
*Applies MacTahoe-Dark-orange, macOS Tahoe orange icons, orange accent color, window buttons on left, and links GTK4 styles to `~/.config/gtk-4.0/` so Nautilus displays macOS Tahoe styling.*

### 2. Apply macOS Boot Splash, GRUB & Login Screen (Requires Sudo)
```bash
sudo ./setup_startup_and_login.sh
```
*Installs the silent Apple boot splash (cleans up any stuck "updating..." flags), builds and applies the macOS GDM login screen, and configures the GRUB theme with properly encoded 8-bit RGB hero image.*

### 3. Master One-Shot Installer (Runs Both Steps)
```bash
./install_all.sh
```

### 4. Restore Factory Settings
If you ever want to revert GRUB, Plymouth and GDM back to Debian defaults:
```bash
sudo ./setup_startup_and_login.sh --restore
```
