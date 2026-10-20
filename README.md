# Chroma Control for macOS 🐍⌨️

A lightweight, native macOS application designed according to **Apple Human Interface Guidelines (HIG)** and styled with the **GitHub Dark Color Theme** for controlling RGB lighting and performance across your gaming desk peripherals:
* **Razer Basilisk V3** (and other Razer Chroma mice)
* **Attack Shark X98** (and related mechanical keyboards)

Built using **SwiftUI** and a direct **Apple IOKit USB HID** driver interface. Zero telemetry, no cloud/browser dependencies, no account required, and 100% native.

![macOS 13+](https://img.shields.io/badge/macOS-13.0%2B-blue)
![Architecture](https://img.shields.io/badge/Architecture-Apple%20Silicon%20%7C%20Intel-green)
![Devices](https://img.shields.io/badge/Devices-Mouse%20%2B%20Keyboard-orange)
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
  * Accent Colors: GitHub Green (`#238636` / `#2ea043`), GitHub Purple (`#8957e5` / `#a371f7`), Crimson Red (`#da3633` / `#f85149`), GitHub Blue (`#58a6ff`).
* **High-Fidelity Hardware Previews**:
  * Real-time 2D ergonomic silhouette for Razer Basilisk V3 with individual Scroll, Logo, and 11-underglow LED rendering.
  * Real-time 98-key south-facing mechanical keyboard simulation reflecting per-key LED states.

---

## ⚡ Features

### 🌟 1. Combined & Separate Control Modes
* **Ecosystem Sync (Combined)**: One-click sync that coordinates both the Razer Basilisk V3 mouse and the Attack Shark X98 keyboard with matching desk themes:
  * **Gamer Custom: Red & Purple**: Crimson Red accents & Violet Purple underglow on the Basilisk V3, synchronized with the per-key Red & Purple matrix on the Attack Shark X98.
  * **Sith Lord Red**: Aggressive crimson red across both peripherals.
  * **GitHub / Razer Emerald**: Clean high-contrast developer green across all hardware.
  * **Cyberpunk High Voltage**: Electric yellow mouse underglow with cyan keyboard wave.
  * **Deep Ocean Horizon**: Royal blue across desk gear.
  * **Spectrum Cycling**: Synchronized flowing rainbow animation.
  * **Stealth Blackout**: Instant shutdown of all LEDs.
  * **Master Ecosystem Brightness**: Adjusts brightness for all devices simultaneously.
* **Independent Device Control (Separate)**: Dedicated standalone customization tabs for each device.

---

### ⌨️ 2. Attack Shark X98 Keyboard Controls
* **Direct USB HID Integration**: Direct communication via the 64-byte vendor-defined pipe (`UsagePage = 0xFF02, Usage = 2`) through Apple `IOKit`, bypassing browser WebHID security blocks on macOS.
* **Custom Per-Key RGB Matrix (`FEA_CMD_SET_USERPIC = 0x0C`)**:
  * Sends custom RGB colors across 7 sequential 64-byte packets with bit-7 checksums, followed by mode 13 (`LightUserPicture`) activation via `0x07`.
  * **Gamer Custom Layout (One-Click Preset)**:
    * **Crimson Red**: Function keys (F1–F12), Esc, Tab, Caps Lock, both Shifts, both Ctrls, both Alts, both Windows/GUI keys, Fn, Enter, Backspace, Arrow keys (Up/Down/Left/Right), and WASD.
    * **Violet Purple**: All remaining alphanumeric, numpad, and navigation cluster keys.
* **21 Hardware Lighting Modes (`FEA_CMD_SET_LEDPARAM = 0x07`)**:
  * Static Solid, Neon Wave, Breathing, Ripple Spread, Raindrop/Stars, Key Trigger Reactive, Spectrum Cycling, Snake Trail, Aurora Borealis, Sine Wave, Shadow Follow, Laser Sweep, Vortex Swirl, and Off.
* **Hardware Speed & Brightness Sliders**: Step-controlled to match MCU register boundaries.

---

### 🖱️ 3. Razer Basilisk V3 Mouse Controls
* **Per-Zone Addressable RGB**:
  * Scroll Wheel LED
  * Razer Logo (Palm Rest)
  * 11-LED Multi-Zone Underglow Rim
* **Chroma Effects**: Static Solid, Breathing (Single/Dual/Random), Spectrum Cycling, Wave, Reactive, Off.
* **Performance Tuning**:
  * Sensor DPI adjustment up to 26,000 DPI (presets: `400`, `800`, `1600`, `3200`, `6400`).
  * Hardware Polling Rate selector (`125 Hz`, `500 Hz`, `1000 Hz`).
* **Onboard Flash Memory (`VARSTORE`)**: Writes directly to onboard non-volatile memory, persisting settings without software running in the background.

---

## 🔍 Attack Shark X98 Hardware Protocol Details

1. **Packet Structure & Checksum**:
   * Mode / Solid Color Command: `buf[0] = 0x07` (`FEA_CMD_SET_LEDPARAM`).
   * The firmware verifies checksum at **byte index 8**:
     $$\text{checksum} = 255 - \left(\sum_{i=0}^{7} \text{buf}[i] \ \& \ 0xFF\right)$$
   * Custom Matrix Command: `buf[0] = 0x0C` (`FEA_CMD_SET_USERPIC`) transmits 7 sequential 64-byte chunks with bit-7 checksum at byte index 7.
2. **Why Web Drivers (`qmk.top`) Fail on macOS**:
   * macOS `AppleUserHIDEventService` claims standard keyboard interfaces. ChromaControl bypasses this restriction by addressing the `0xFF02` vendor-defined interface natively through `IOHIDDeviceSetReport(..., kIOHIDReportTypeOutput)`.
3. **Onboard Hardware Shortcuts**:
   * When running on Bluetooth or 2.4GHz wireless:
     * **`Fn` + `\|`**: Cycle 21 internal effects.
     * **`Fn` + `Enter`**: Cycle 7 primary colors.
     * **`Fn` + `↑` / `↓`**: Adjust brightness.
     * **`Fn` + `←` / `→`**: Adjust speed.

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

GPL-2.0 License. Reverse-engineered protocols adapted from open-source research across OpenRazer, librazermacos, and QMK.Top.
