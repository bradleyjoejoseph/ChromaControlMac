import Foundation
import SwiftUI
import IOKit
import IOKit.hid

public enum KeyboardEffect: String, CaseIterable, Identifiable {
    case staticColor = "Static Solid"
    case wave = "Neon Wave"
    case breathing = "Breathing"
    case ripple = "Ripple Spread"
    case raindrop = "Raindrop / Stars"
    case reactive = "Key Reactive"
    case spectrum = "Spectrum Cycling"
    case snake = "Snake Trail"
    case aurora = "Aurora Borealis"
    case sineWave = "Sine Wave"
    case shadows = "Shadow Follow"
    case laser = "Laser Sweep"
    case vortex = "Vortex Swirl"
    case userPicture = "Custom User Matrix"
    case off = "LEDs Off (Stealth)"

    public var id: String { rawValue }

    public var modeIndex: UInt8 {
        switch self {
        case .wave: return 4
        case .staticColor: return 1
        case .breathing: return 2
        case .ripple: return 5
        case .raindrop: return 6
        case .reactive: return 8
        case .spectrum: return 3
        case .snake: return 7
        case .aurora: return 16
        case .sineWave: return 10
        case .shadows: return 9
        case .laser: return 14
        case .vortex: return 15
        case .userPicture: return 13
        case .off: return 0
        }
    }

    public var icon: String {
        switch self {
        case .staticColor: return "sun.max.fill"
        case .wave: return "water.waves"
        case .breathing: return "wind"
        case .ripple: return "dot.radiowaves.left.and.right"
        case .raindrop: return "sparkles"
        case .reactive: return "bolt.fill"
        case .spectrum: return "rainbow"
        case .snake: return "point.topleft.down.curvedto.point.bottomright.up"
        case .aurora: return "cloud.sun.fill"
        case .sineWave: return "waveform.path"
        case .shadows: return "moon.fill"
        case .laser: return "rays"
        case .vortex: return "tornado"
        case .userPicture: return "square.grid.3x3.fill"
        case .off: return "lightbulb.slash"
        }
    }
}

public enum KeyboardColor: String, CaseIterable, Identifiable {
    case red = "Crimson Red"
    case purple = "Violet Purple"
    case green = "Emerald Green"
    case blue = "Royal Blue"
    case yellow = "Sunshine Yellow"
    case cyan = "Electric Cyan"
    case white = "Pure White"

    public var id: String { rawValue }

    public var rgb: (r: UInt8, g: UInt8, b: UInt8) {
        switch self {
        case .red: return (255, 0, 0)
        case .purple: return (160, 0, 255)
        case .green: return (0, 255, 60)
        case .blue: return (0, 100, 255)
        case .yellow: return (255, 215, 0)
        case .cyan: return (0, 230, 255)
        case .white: return (255, 255, 255)
        }
    }

    public var displayColor: Color {
        let (r, g, b) = rgb
        return Color(red: Double(r)/255.0, green: Double(g)/255.0, blue: Double(b)/255.0)
    }
}

public class AttackSharkManager: ObservableObject {
    public static let shared = AttackSharkManager()

    @Published public var isConnected: Bool = false
    @Published public var deviceName: String = "Attack Shark X98 (Scanning...)"
    @Published public var selectedEffect: KeyboardEffect = .userPicture
    @Published public var selectedColor: KeyboardColor = .purple
    @Published public var brightness: Double = 100.0 // 0 to 4 steps internally
    @Published public var speed: Double = 50.0 // 0 to 4 steps internally
    @Published public var lastStatusMessage: String = "Ready"
    @Published public var isCustomMatrixActive: Bool = true
    @Published public var customMatrixPresetName: String = "Gamer Red & Purple"

    private var hidManager: IOHIDManager?
    private var keyboardDevice: IOHIDDevice?
    private var pollTimer: Timer?
    private let queue = DispatchQueue(label: "com.antigravity.attackshark.hardware", qos: .userInitiated)

    // Robust union of key matrix positions covering both X98 MCU matrix variants
    public static let gamerRedPositions: Set<Int> = [
        0,   // Esc
        2,   // Tab
        3,   // Caps Lock
        4,   // Left Shift
        5,   // Left Ctrl
        6,   // F1 (Variant A)
        9,   // A
        11,  // Left Win / Command
        12,  // F2 (Variant A) / F1 (Variant B)
        14,  // W
        15,  // S
        17,  // Left Alt / Option
        18,  // F3 (Variant A) / F2 (Variant B)
        21,  // D
        23,  // Left Alt secondary
        24,  // F4 (Variant A) / F3 (Variant B)
        30,  // F5 (Variant A) / F4 (Variant B)
        36,  // F6 (Variant A) / F5 (Variant B)
        42,  // F7 (Variant A) / F6 (Variant B)
        48,  // F8 (Variant A) / F7 (Variant B)
        53,  // Right Alt
        54,  // F9 (Variant A) / F8 (Variant B)
        60,  // F10 (Variant A) / F9 (Variant B)
        65,  // Right Alt / Right Ctrl
        66,  // F11 (Variant A) / F10 (Variant B)
        71,  // Right Ctrl (Variant B)
        72,  // F12 (Variant A) / F11 (Variant B)
        76,  // Right Shift
        77,  // Left Arrow (Variant B) / Right Ctrl
        78,  // F12 (Variant B)
        79,  // Backspace
        81,  // Enter
        82,  // Up Arrow (Variant B)
        83,  // Left Arrow (Variant A) / Down Arrow (Variant B)
        88,  // Up Arrow (Variant A)
        89,  // Down Arrow (Variant A) / Right Arrow (Variant B)
        95,  // Right Arrow (Variant A)
        101, // Fn / App Key
        102, // Fn / Alt
        113, // Numpad Enter
        114, // Fn
        115  // Fn
    ]

    public init() {
        setupHIDManager()
        refreshConnection()
        startPolling()
    }

    deinit {
        pollTimer?.invalidate()
        if let mgr = hidManager {
            IOHIDManagerClose(mgr, IOOptionBits(kIOHIDOptionsTypeNone))
        }
    }

    private func setupHIDManager() {
        hidManager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        guard let mgr = hidManager else { return }

        let matchDict: [String: Any] = [
            kIOHIDVendorIDKey: 6700, // 0x1A2C (Shinetek / Semico)
            kIOHIDProductIDKey: 41012 // 0xA034 (Attack Shark X98)
        ]
        IOHIDManagerSetDeviceMatching(mgr, matchDict as CFDictionary)
        IOHIDManagerOpen(mgr, IOOptionBits(kIOHIDOptionsTypeNone))
    }

    public func startPolling() {
        pollTimer?.invalidate()
        pollTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { [weak self] _ in
            self?.refreshConnection()
        }
    }

    public func refreshConnection() {
        queue.async {
            guard let mgr = self.hidManager else { return }
            var found = false
            var targetDev: IOHIDDevice?

            if let deviceSet = IOHIDManagerCopyDevices(mgr) as? Set<IOHIDDevice> {
                for dev in deviceSet {
                    let usagePage = IOHIDDeviceGetProperty(dev, kIOHIDPrimaryUsagePageKey as CFString) as? Int ?? 0
                    let maxOut = IOHIDDeviceGetProperty(dev, kIOHIDMaxOutputReportSizeKey as CFString) as? Int ?? 0
                    if usagePage == 0xFF02 && maxOut >= 64 {
                        found = true
                        targetDev = dev
                        break
                    }
                }
            }

            DispatchQueue.main.async {
                self.isConnected = found
                self.keyboardDevice = targetDev
                if found {
                    self.deviceName = "Attack Shark X98 Mechanical Keyboard"
                } else {
                    self.deviceName = "Attack Shark X98 (Not connected via USB)"
                }
            }
        }
    }

    // Standard Hardware Effects & Solid Colors (Command 0x07)
    public func applyLighting() {
        let effect = self.selectedEffect
        let color = self.selectedColor
        let brightLevel = UInt8(max(0, min(4, Int(round(self.brightness / 25.0)))))
        let speedLevel = UInt8(max(0, min(4, Int(round(self.speed / 25.0)))))

        // If custom matrix is selected, divert to custom preset
        if effect == .userPicture {
            applyGamerRedAndPurplePreset()
            return
        }

        queue.async {
            guard let dev = self.keyboardDevice else {
                DispatchQueue.main.async {
                    self.lastStatusMessage = "Keyboard not reachable via USB HID"
                }
                return
            }

            var buf = [UInt8](repeating: 0, count: 64)
            buf[0] = 0x07 // FEA_CMD_SET_LEDPARAM
            buf[1] = effect.modeIndex
            buf[2] = speedLevel
            buf[3] = brightLevel
            buf[4] = 0

            let rgb = color.rgb
            buf[5] = rgb.r
            buf[6] = rgb.g
            buf[7] = rgb.b

            // Checksum at byte index 8 (sum of bytes 0..7)
            var sum8: UInt32 = 0
            for i in 0..<8 { sum8 += UInt32(buf[i]) }
            buf[8] = UInt8((255 - (sum8 & 0xFF)) & 0xFF)

            let result = IOHIDDeviceSetReport(dev, kIOHIDReportTypeOutput, 0, buf, 64)
            let success = (result == kIOReturnSuccess)

            DispatchQueue.main.async {
                self.isCustomMatrixActive = false
                let formatter = DateFormatter()
                formatter.timeStyle = .medium
                if success {
                    self.lastStatusMessage = "\(effect.rawValue) applied (\(formatter.string(from: Date())))"
                } else {
                    self.lastStatusMessage = "Hardware command error 0x\(String(format: "%08X", result))"
                }
            }
        }
    }

    // Custom Per-Key Matrix Lighting: RED on requested keys, PURPLE on all remaining keys
    public func applyGamerRedAndPurplePreset() {
        queue.async {
            guard let dev = self.keyboardDevice else {
                DispatchQueue.main.async {
                    self.lastStatusMessage = "Keyboard not reachable via USB HID"
                }
                return
            }

            // 128 keys * 3 RGB bytes = 384 bytes, rounded up to 7 chunks * 56 = 392 bytes
            var matrixRGB = [UInt8](repeating: 0, count: 392)

            // Default: Violet Purple (#A000FF: 160, 0, 255)
            let purpleR: UInt8 = 160
            let purpleG: UInt8 = 0
            let purpleB: UInt8 = 255

            for i in 0..<128 {
                matrixRGB[i * 3]     = purpleR
                matrixRGB[i * 3 + 1] = purpleG
                matrixRGB[i * 3 + 2] = purpleB
            }

            // Red: Crimson Red (255, 0, 0)
            let redR: UInt8 = 255
            let redG: UInt8 = 0
            let redB: UInt8 = 0

            for pos in AttackSharkManager.gamerRedPositions {
                if pos < 128 {
                    matrixRGB[pos * 3]     = redR
                    matrixRGB[pos * 3 + 1] = redG
                    matrixRGB[pos * 3 + 2] = redB
                }
            }

            // Transmit 7 chunks of Command 0x0C (FEA_CMD_SET_USERPIC)
            let rVal = 384
            var allChunksSuccess = true

            for chunk in 0..<7 {
                var packet = [UInt8](repeating: 0, count: 64)
                packet[0] = 12 // FEA_CMD_SET_USERPIC
                packet[1] = 0
                packet[2] = UInt8(rVal & 0xFF)
                packet[3] = UInt8((rVal >> 8) & 0xFF)
                packet[4] = UInt8(chunk)
                packet[5] = 0
                packet[6] = 0

                // Checksum at byte 7: 255 - (sum(packet[0..6]) & 0xFF)
                var sum7: UInt32 = 0
                for k in 0..<7 { sum7 += UInt32(packet[k]) }
                packet[7] = UInt8((255 - (sum7 & 0xFF)) & 0xFF)

                // 56 RGB data payload bytes
                for b in 0..<56 {
                    let srcIdx = chunk * 56 + b
                    if srcIdx < matrixRGB.count {
                        packet[8 + b] = matrixRGB[srcIdx]
                    }
                }

                let ret = IOHIDDeviceSetReport(dev, kIOHIDReportTypeOutput, 0, packet, 64)
                if ret != kIOReturnSuccess {
                    allChunksSuccess = false
                }
                usleep(15000) // 15ms interval between chunks
            }

            usleep(50000) // 50ms pause before activating

            // Activate custom matrix on MCU via 0x07 with mode 13 (LightUserPicture)
            let brightLevel = UInt8(max(0, min(4, Int(round(self.brightness / 25.0)))))
            var cmd = [UInt8](repeating: 0, count: 64)
            cmd[0] = 0x07 // FEA_CMD_SET_LEDPARAM
            cmd[1] = 13   // LightUserPicture
            cmd[2] = 2    // speed
            cmd[3] = brightLevel
            cmd[4] = 0
            cmd[5] = 0
            cmd[6] = 200
            cmd[7] = 200

            var sum8: UInt32 = 0
            for k in 0..<8 { sum8 += UInt32(cmd[k]) }
            cmd[8] = UInt8((255 - (sum8 & 0xFF)) & 0xFF)

            let retCmd = IOHIDDeviceSetReport(dev, kIOHIDReportTypeOutput, 0, cmd, 64)
            let overallSuccess = allChunksSuccess && (retCmd == kIOReturnSuccess)

            DispatchQueue.main.async {
                self.isCustomMatrixActive = true
                self.selectedEffect = .userPicture
                self.customMatrixPresetName = "Gamer Red & Purple"
                let formatter = DateFormatter()
                formatter.timeStyle = .medium
                if overallSuccess {
                    self.lastStatusMessage = "Gamer Layout Active (Red & Purple) (\(formatter.string(from: Date())))"
                } else {
                    self.lastStatusMessage = "Preset sent (Return code: 0x\(String(format: "%08X", retCmd)))"
                }
            }
        }
    }
}
