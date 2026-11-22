# Obsidian Amber, Maple Red & Developer Power Splash Suite
### macOS Ergonomics, Windows 11 Start Menu, QLED Optimizations & Developer Identity

A complete, automated UI customization suite designed for **Debian 13 (Trixie) / GNOME 48** with dedicated optimizations for **QLED wide-gamut displays** and **Software Developers**.

Zero manual git cloning or file hunting required.

---

## 🌟 Visual Architecture

| Component | Theme & Style | Palette |
| :--- | :--- | :--- |
| **Power On / GRUB** | Native-Resolution Bootloader with Maple Wallpaper | Radiant **Maple Red** (`#99141e`) to **Pure Deep Black** (`#000000`) |
| **Powering Up / Off** | 180x180 Animated Cyber-Developer Core + Blinking Terminal Title | **Vibrant Maple Red & Crimson Gold (`#ff3b30` / `#ffeaa7`)** on Pure Black |
| **Login Screen (GDM)** | macOS Frosted Glass Card + Pinterest Wallpaper | **Crimson Ruby (`#cd1337`)** Accent & Focus Rings |
| **Desktop Environment** | macOS Floating Dock + Top Bar Blur | Obsidian Amber (`#0e0906`, `#c67c0d`, `#e5b869`) |
| **Start Menu** | Windows 11 Centered Layout + macOS Frosted Glass | ArcMenu 11 with 22px curvature & pill search |

---

## 💻 Software Developer Power-On Splash

The power-on animation features a full developer identity design:
1. **180x180 Cyber Developer Core**: Outer rotating tech HUD ring with tick-marks and inner counter-rotating fluid comet trail, centered with a glowing `>_` terminal prompt.
2. **Animated Developer Title Badge**: A frosted terminal badge displaying `>_ [YOUR_TITLE]` with a live blinking Unix terminal cursor (`█`).
3. **Offline Update Progress Display**: Implements `Plymouth.SetUpdateStatusFunction` and `Plymouth.SetMessageFunction` so system updates (e.g., "INSTALLING UPDATES: 45%...") and disk check messages are displayed cleanly in monospace tech typography.

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
You can enter your custom title interactively or pass it via `--title`:
```bash
sudo ./setup_startup_and_login.sh --title "JOSEPH // SOFTWARE ARCHITECT"
```
*(If run without `--title`, the script prompts you to enter your title)*

### 3. Master One-Shot Installer (Runs Both Steps)
```bash
./install_all.sh --title "JOSEPH // SOFTWARE ARCHITECT"
```

### 4. Restore Factory Settings
If you ever want to revert GRUB and Plymouth back to Debian defaults:
```bash
sudo ./setup_startup_and_login.sh --restore
```

---

## 📦 Pushing to Your GitHub

This repository is initialized with all assets and ready to push to your GitHub account:

```bash
cd /home/joseph/Desktop/grub_modify
git remote add origin https://github.com/gatirijose/grub-desktop-customizer.git
git branch -M main
git push -u origin main
```
