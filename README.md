# Chroma Control for macOS 🐍⌨️

A lightweight, native macOS GUI application for controlling RGB lighting and performance across your entire gaming desk ecosystem:
* **Razer Basilisk V3** (and other Razer Chroma mice)
* **Attack Shark X98** (and related mechanical keyboards)

Built using **SwiftUI** and a direct **IOKit USB HID** driver interface. Zero telemetry, no cloud/browser dependencies, no account required, and 100% native.

![macOS 13+](https://img.shields.io/badge/macOS-13.0%2B-blue)
![Architecture](https://img.shields.io/badge/Architecture-Apple%20Silicon%20%7C%20Intel-green)
![Devices](https://img.shields.io/badge/Devices-Mouse%20%2B%20Keyboard-orange)
![License](https://img.shields.io/badge/License-GPLv2-green)

---

## ⚡ Features

### 🌟 1. Combined & Separate Control Modes
* **Ecosystem Sync (Combined)**: One-click sync that coordinates both the Razer Basilisk V3 mouse and the Attack Shark X98 keyboard with unified desk themes:
  * **Sith Lord Red**: Aggressive crimson red across both devices.
  * **Razer Signature**: Tournament-standard neon green.
  * **Cyberpunk 2077**: Electric yellow mouse underglow with cyan keyboard wave.
  * **Deep Ocean Blue**: Royal blue across desk gear.
  * **Spectrum Wave**: Synchronized flowing rainbow animation.
  * **Stealth Blackout**: Instant shutdown of all LEDs.
  * **Master Ecosystem Brightness**: Adjusts brightness for all devices simultaneously.
* **Independent Device Control (Separate)**: Full standalone customization tabs for each device.

---

### 🖱️ 2. Razer Basilisk V3 Mouse Controls
* **Live Hardware Silhouette**: Real-time animated visualizer reflecting your active lighting colors.
* **Per-Zone Control**:
  * **Scroll Wheel LED**
  * **Razer Logo (Palm Rest)**
  * **11-LED Multi-Zone Underglow Rim**
* **Chroma Effects**: Static, Breathing (Single/Dual/Random), Spectrum Cycling, Wave, Reactive, Off.
* **Performance Tuning**:
  * Sensor DPI adjustment up to 26,000 DPI (presets: `400`, `800`, `1600`, `3200`, `6400`).
  * Hardware Polling Rate selector (`125 Hz`, `500 Hz`, `1000 Hz`).
* **Onboard Flash Memory (`VARSTORE`)**: Writes settings directly to the mouse hardware so they persist across reboots and when plugged into other machines without software running.

---

### ⌨️ 3. Attack Shark X98 Keyboard Controls
* **Direct USB HID Integration**: Communicates directly with the keyboard's vendor-defined pipe (`0xFF02:0x0002`) via Apple `IOKit`, bypassing browser WebHID limitations on macOS.
* **21 Hardware Lighting Effects**:
  * Neon Wave, Static Solid, Breathing, Ripple Spread, Raindrop/Stars, Reactive, Spectrum, Snake Trail, Aurora Borealis, Sine Wave, Shadow Follow, Laser, Vortex, and Off.
* **7 Primary Hardware Colors**: Crimson Red, Emerald Green, Royal Blue, Sunshine Yellow, Electric Cyan, Violet Purple, Pure White, and Multi-color.
* **Hardware Speed & Brightness Controls**: 4 granular steps matching the microcontroller's internal tables.

---

## 🔍 Attack Shark X98 Architecture & Limitations

1. **Integrated Shinetek MCU (`0x1A2C:0xA034`)**:
   * The X98 uses pre-programmed firmware lighting tables inside its microcontroller. Unlike high-end Razer Chroma devices that stream raw uncompressed per-LED video frames over high-bandwidth USB, the X98 executes animations directly on-chip.
   * **Advantage**: Zero CPU usage and no USB polling latency during intense gaming.
   * **Limitation**: The visual effects and colors are determined by the 21 built-in algorithms and 7 hardware colors.
2. **Why Web Drivers (`qmk.top`) Often Fail on Mac**:
   * macOS's `AppleUserHIDEventService` kernel driver locks standard keyboard interfaces for security, preventing browser WebHID from opening the device cleanly. ChromaControl solves this by communicating directly with the vendor-specific `0xFF02` channel at the native OS layer.
3. **Onboard Hardware Shortcuts**:
   * When using the keyboard in wireless 2.4GHz or Bluetooth mode without USB connected, you can use the built-in manual overrides:
     * **`Fn` + `\|`**: Cycle through the 21 lighting effects.
     * **`Fn` + `Enter`**: Cycle through the 7 primary colors.
     * **`Fn` + `↑` / `↓`**: Adjust backlight brightness.
     * **`Fn` + `←` / `→`**: Adjust effect speed.
     * **`Fn` + `Backspace`**: Battery status check.

---

## 🛠️ How to Build & Run

### Build from Source

```bash
# Clone the repository
git clone https://github.com/bradleyjoejoseph/ChromaControlMac.git
cd ChromaControlMac

# Package the standalone .app with icon
./build_app.sh

# Launch the app
open build/ChromaControl.app
```

---

## 📄 License

GPL-2.0 License. Reverse-engineered protocols adapted from open-source research across the OpenRazer, librazermacos, and QMK.Top communities.
