# Chroma Control for macOS 🐍🖱️

A lightweight, native macOS application designed according to **Apple Human Interface Guidelines (HIG)** and styled with the **GitHub Dark Color Theme** for controlling RGB lighting and performance on the **Razer Basilisk V3** (and other Razer Chroma mice).

Built using **SwiftUI** and a direct **Apple IOKit USB HID** driver interface. Zero telemetry, no cloud/browser dependencies, no account required, and 100% native.

![macOS 13+](https://img.shields.io/badge/macOS-13.0%2B-blue)
![Architecture](https://img.shields.io/badge/Architecture-Apple%20Silicon%20%7C%20Intel-green)
![Device](https://img.shields.io/badge/Device-Razer%20Basilisk%20V3-brightgreen)
![Design](https://img.shields.io/badge/Design-Apple%20HIG%20%7C%20GitHub%20Theme-purple)
![License](https://img.shields.io/badge/License-GPLv2-green)

---

## 🎨 UI Design System

* **Apple HIG & GitHub Dark Palette**:
  * Default Canvas: `#0d1117`
  * Subtle Surfaces & Sidebar: `#161b22`
  * Inset Cards & Controls: `#21262d`
  * Native Borders: `#30363d`
  * Primary Text: `#f0f6fc`
  * Secondary Text: `#8b949e`
  * Accents: GitHub Green (`#238636` / `#2ea043`), GitHub Purple (`#8957e5`), Crimson Red (`#da3633`), Blue (`#58a6ff`).
* **Live Hardware Silhouette**:
  * Real-time 2D ergonomic silhouette for Razer Basilisk V3 with individual Scroll, Logo, and 11-underglow LED rendering.

---

## ⚡ Features

### 🖱️ 1. Chroma Lighting Control
* **Per-Zone Addressable RGB**:
  * **Scroll Wheel LED**
  * **Razer Logo (Palm Rest)**
  * **11-LED Multi-Zone Underglow Rim**
* **Chroma Effects**:
  * Static Solid (Custom RGB & Presets)
  * Breathing (Single Color, Dual Color, Random Spectrum)
  * Spectrum Cycling (16.8 million colors)
  * Neon Wave (Forward / Reverse direction)
  * Key Trigger Reactive (1s to 4s duration)
  * Stealth Blackout (Instant off)
* **Master Brightness Slider**: 0% to 100% fine-grained control.

### ⚡ 2. Sensor & Performance Tuning
* **DPI Sensitivity**:
  * Fine slider tuning up to 26,000 DPI.
  * Quick tournament stages (`400`, `800`, `1600`, `3200`, `6400`).
* **Hardware Polling Rate**:
  * `125 Hz` (8.0ms)
  * `500 Hz` (2.0ms)
  * `1000 Hz` (1.0ms esports response)

### 💾 3. Hardware Flash Persistence (`VARSTORE`)
* Directly writes settings to the mouse's onboard non-volatile memory (`VARSTORE`).
* Settings stay saved even after machine reboots, unplugging, or moving the mouse to another computer without software running.

---

## 🛠️ Build & Run

```bash
# Clone repository
git clone https://github.com/bradleyjoejoseph/ChromaControlMac.git
cd ChromaControlMac

# Build & bundle standalone .app with AppIcon
./build_app.sh

# Launch the app
open build/ChromaControl.app
```

---

## 📄 License

GPL-2.0 License. Reverse-engineered protocols adapted from open-source research across OpenRazer and librazermacos.
