# Chroma Control for macOS 🐍

A lightweight, native macOS GUI application for controlling Razer Chroma RGB lighting, DPI sensitivity stages, and polling rates on Razer mice (including the **Razer Basilisk V3**).

Built using **SwiftUI** and a direct **IOKit USB HID** driver interface based on clean-room reverse-engineered Razer protocols. Zero telemetry, no account required, and blazing fast.

![macOS 13+](https://img.shields.io/badge/macOS-13.0%2B-blue)
![Architecture](https://img.shields.io/badge/Architecture-Apple%20Silicon%20%7C%20Intel-green)
![License](https://img.shields.io/badge/License-GPLv2-green)

---

## Features

### 🌈 Complete Chroma Lighting Engine
* **Interactive Live Mouse Preview**: Visual representation of the Razer Basilisk V3 showing real-time animated RGB feedback for each zone.
* **Lighting Zones**:
  * **Synchronized Mode**: Uniform color/effects across the whole mouse.
  * **Per-Zone Control**: Customize individual zones independently:
    * **Scroll Wheel LED**
    * **Razer Logo LED**
    * **11-Zone Multi-LED Underglow / Base Rim**
* **Hardware Chroma Effects**:
  * **Static**: Set any solid color from the curated Chroma palette, native color picker, or direct HEX input.
  * **Breathing**: Smooth pulsing with single color, dual alternating colors, or random spectrum.
  * **Spectrum Cycling**: Continuous smooth rainbow transition across the 16.8M color spectrum.
  * **Wave**: Moving rainbow wave with configurable direction (forward / reverse).
  * **Reactive**: Illuminates dynamically upon mouse clicking with configurable duration.
  * **Off / Stealth**: Complete blackout for distraction-free gaming or battery saving.
* **Master Brightness**: Slider control from 0% to 100%.
* **Onboard Memory Storage (`VARSTORE`)**: Writes your configuration directly to the mouse's internal hardware flash so your settings persist across reboots or when switching computers, even without the app running!

---

### ⚡ Performance & Sensor Controls
* **DPI Sensitivity**: Adjust sensor sensitivity up to 26,000 DPI, with one-click esports stages (`400`, `800`, `1600`, `3200`, `6400`).
* **Polling Rate**: Toggle hardware polling frequency between `125 Hz` (8ms), `500 Hz` (2ms), and `1000 Hz` (1ms response time).

---

### 🎨 Quick Profiles
One-click lighting and performance presets:
* **Sith Lord Red**: Aggressive crimson red across all 11 zones.
* **Razer Signature**: Tournament-ready iconic Razer neon green.
* **Cyberpunk 2077**: Electric yellow underglow with neon cyan scroll wheel.
* **Vaporwave Synth**: Hot magenta palm logo with violet underglow.
* **Spectrum Wave**: Dynamic animated rainbow ripples.
* **Stealth Blackout**: Complete LED shutdown.

---

## Compatibility

Tested and optimized for:
* **Razer Basilisk V3** (`0x1532:0x0099`)
* **Razer Basilisk V3 Pro** (`0x1532:0x00AA`)
* **Razer Basilisk V2** (`0x1532:0x0085`)
* Other Chroma-enabled Razer mice sharing the extended matrix protocol (DeathAdder V2, Viper Ultimate, etc.).

---

## How to Build & Run

### Prerequisites
* macOS 13.0 (Ventura) or newer
* Apple Silicon (M1/M2/M3/M4) or Intel Mac
* Xcode Command Line Tools (`xcode-select --install`)

### Building from Source

```bash
# Clone the repository
git clone https://github.com/bradleyjoejoseph/ChromaControlMac.git
cd ChromaControlMac

# Build debug or release
swift build -c release

# Launch the app
./.build/release/ChromaControl
```

### Creating the `.app` Bundle

```bash
mkdir -p build/ChromaControl.app/Contents/MacOS
cp .build/release/ChromaControl build/ChromaControl.app/Contents/MacOS/
cp build/Info.plist build/ChromaControl.app/Contents/
open build/ChromaControl.app
```

---

## Architecture & How It Works

1. **`CRazerDriver` (C / IOKit)**:
   Communicates directly with the USB device via Apple's `IOKit.framework` and `CoreFoundation.framework`. Formats USB control transfers into standard 90-byte Razer report payloads (`struct razer_report`) with CRC verification.
2. **`RazerHardwareManager` (Swift)**:
   Exposes high-level Swift APIs with thread-safe background dispatch queues and automatic USB device hotplug detection.
3. **`ChromaControl` (SwiftUI)**:
   Native macOS UI matching Apple Human Interface Guidelines and Razer's modern aesthetic.

---

## License

GPL-2.0 License. Based on protocol research and hardware driver implementations from the open-source [OpenRazer](https://github.com/openrazer/openrazer) and [librazermacos](https://github.com/stickoking/librazermacos) communities.
