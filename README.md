# Obsidian Amber & Maple Red Customization Suite
### macOS Ergonomics, Windows 11 Centered Start Menu & QLED Power Animations

A complete, automated UI customization suite designed for **Debian 13 (Trixie) / GNOME 48** with dedicated optimizations for **QLED wide-gamut displays**.

Zero manual git cloning or file hunting required.

---

## 🌟 Visual Architecture

| Component | Theme & Style | Palette |
| :--- | :--- | :--- |
| **Power On / GRUB** | Minimal Silent Bootloader with Custom Theme | Radiant **Maple Red** (`#99141e`) to **Pure Deep Black** (`#000000`) |
| **Powering Up / Off** | Plymouth Splash Animation (Boot & Shutdown) | Fluid 32-bit ARGB **Glowing Maple Comet Ring** on Pure Black |
| **Login Screen (GDM)** | macOS Sequoia Frosted Glass Card | Custom Wallpaper ([Hero_Banner_MLM.avif](file:///home/joseph/Desktop/grub_modify/Hero_Banner_MLM.avif)) + Amber Accents |
| **Desktop Environment** | macOS Floating Dock + Top Bar Blur | Obsidian Amber (`#0e0906`, `#c67c0d`, `#e5b869`) |
| **Start Menu** | Windows 11 Centered Layout + macOS Frosted Glass | ArcMenu 11 with 22px curvature & pill search |

---

## 📺 QLED Display Optimization

This suite is crafted specifically for high-contrast **Quantum Dot LED (QLED)** and OLED laptop panels:
1. **Pure True Blacks (`#000000`)**: The boot and shutdown screens fade into true zero-nit black, enabling local dimming backlights to turn completely off for infinite contrast and zero backlight bleed.
2. **Wide Color Gamut (DCI-P3)**: High-chroma saturated Maple Red (`#ff3b30`, `#e61e2b`, `#99141e`) takes full advantage of Quantum Dot color vibrancy.
3. **Smooth Anti-Banding**: Gradients and vector animations are pre-rendered with silky smooth 16-bit color channels and hardware anti-aliasing via Cairo.

---

## ⚡ Keyboard Shortcuts (Windows Ergonomics)

| Shortcut | Action |
| :--- | :--- |
| **`Super`** | Open Windows 11 Centered Start Menu (ArcMenu) |
| **`Super + E`** | Open File Explorer (Nautilus) |
| **`Super + D`** | Toggle Show Desktop (Minimize / Restore All) |
| **`Super + L`** | Lock Screen |
| **`Super + I`** | Open System Settings |
| **`Super + V`** | Open Clipboard History |
| **`Super + Left` / `Right`** | Snap Window to Left / Right Half |
| **`Super + Up` / `Down`** | Maximize / Restore Window |
| **`Alt + Tab`** | Switch Windows |
| **`Alt + F4`** | Close Active Window |
| **`Ctrl + Shift + Esc`** | Open Task Manager (GNOME System Monitor) |
| **`Super + Shift + S`** | Interactive Snipping Tool / Screenshot UI |

---

## 🚀 Installation & Usage

### 1. Apply Desktop Environment & Shortcuts (User-Level, No Root Needed)
```bash
./apply_desktop_theme.sh
```

### 2. Apply Maple Red Power Splash, Silent Boot & Login Screen (Requires Sudo)
```bash
sudo ./setup_startup_and_login.sh
```

### 3. Master One-Shot Installer (Runs Both Steps)
```bash
./install_all.sh
```

### 4. Restore Factory Settings
If you ever want to revert GRUB and Plymouth back to Debian defaults:
```bash
sudo ./setup_startup_and_login.sh --restore
```

---

## 📦 Pushing to Your GitHub

This repository is already initialized with all assets and ready to push to your GitHub account:

```bash
# 1. Create a new repository on GitHub (e.g., 'grub-desktop-customizer')
# 2. Link your remote (HTTPS or SSH):
git remote add origin https://github.com/gatirijose/grub-desktop-customizer.git

# 3. Push your main branch:
git branch -M main
git push -u origin main
```
