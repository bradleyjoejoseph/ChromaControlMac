import Foundation
import SwiftUI
import IOKit
import IOKit.hid

public enum KeyboardEffect: String, CaseIterable, Identifiable {
    case wave = "Neon Wave"
    case staticColor = "Static Solid"
    case breathing = "Breathing"
    case ripple = "Ripple Spread"
    case raindrop = "Raindrop / Stars"
    case reactive = "Key Trigger Reactive"
    case spectrum = "Spectrum Cycling"
    case snake = "Snake Trail"
    case aurora = "Aurora Borealis"
    case sineWave = "Sine Wave"
    case shadows = "Shadow Follow"
    case laser = "Laser Sweep"
    case vortex = "Vortex Swirl"
    case off = "LEDs Off (Stealth)"

    public var id: String { rawValue }

    public var modeIndex: UInt8 {
        switch self {
        case .wave: return 0
        case .staticColor: return 1
        case .breathing: return 2
        case .ripple: return 3
        case .raindrop: return 4
        case .reactive: return 5
        case .spectrum: return 6
        case .snake: return 7
        case .aurora: return 8
        case .sineWave: return 9
        case .shadows: return 10
        case .laser: return 11
        case .vortex: return 12
        case .off: return 20
        }
    }

    public var icon: String {
        switch self {
        case .wave: return "water.waves"
        case .staticColor: return "sun.max.fill"
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
        case .off: return "lightbulb.slash"
        }
    }
}

public enum KeyboardColor: String, CaseIterable, Identifiable {
    case red = "Crimson Red"
    case green = "Emerald Green"
    case blue = "Royal Blue"
    case yellow = "Sunshine Yellow"
    case cyan = "Electric Cyan"
    case purple = "Violet Purple"
    case white = "Pure White"
    case multi = "Rainbow Multi"

    public var id: String { rawValue }

    public var colorIndex: UInt8 {
        switch self {
        case .red: return 0
        case .green: return 1
        case .blue: return 2
        case .yellow: return 3
        case .purple: return 4
        case .cyan: return 5
        case .white: return 6
        case .multi: return 7
        }
    }

    public var displayColor: Color {
        switch self {
        case .red: return Color.red
        case .green: return Color.green
        case .blue: return Color(red: 0.0, green: 0.4, blue: 1.0)
        case .yellow: return Color.yellow
        case .cyan: return Color(red: 0.0, green: 0.9, blue: 1.0)
        case .purple: return Color(red: 0.7, green: 0.0, blue: 1.0)
        case .white: return Color.white
        case .multi: return Color.purple
        }
    }
}

public class AttackSharkManager: ObservableObject {
    public static let shared = AttackSharkManager()

    @Published public var isConnected: Bool = false
    @Published public var deviceName: String = "Attack Shark X98 (Scanning...)"
    @Published public var selectedEffect: KeyboardEffect = .staticColor
    @Published public var selectedColor: KeyboardColor = .red
    @Published public var brightness: Double = 100.0 // 4 steps internally
    @Published public var speed: Double = 50.0 // 4 steps internally
    @Published public var lastStatusMessage: String = "Ready"

    private var hidManager: IOHIDManager?
    private var keyboardDevice: IOHIDDevice?
    private var pollTimer: Timer?
    private let queue = DispatchQueue(label: "com.antigravity.attackshark.hardware", qos: .userInitiated)

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
                    if usagePage == 0xFF02 {
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

    public func applyLighting() {
        let effect = self.selectedEffect
        let color = self.selectedColor
        let brightLevel = UInt8(max(0, min(3, Int(self.brightness / 26.0))))
        let speedLevel = UInt8(max(0, min(3, Int(self.speed / 26.0))))

        queue.async {
            guard let dev = self.keyboardDevice else {
                DispatchQueue.main.async {
                    self.lastStatusMessage = "Keyboard not reachable via USB HID"
                }
                return
            }

            // Build 64-byte vendor command packet
            var buf = [UInt8](repeating: 0, count: 64)
            buf[0] = 0x04 // Lighting Command
            buf[1] = effect.modeIndex
            buf[2] = color.colorIndex
            buf[3] = brightLevel
            buf[4] = speedLevel

            // Calculate checksum at index 7
            let sum = (UInt32(buf[0]) + UInt32(buf[1]) + UInt32(buf[2]) + UInt32(buf[3]) + UInt32(buf[4])) & 0xFF
            buf[7] = UInt8((255 - sum) & 0xFF)

            let result = IOHIDDeviceSetReport(dev, kIOHIDReportTypeOutput, 0, buf, buf.count)
            let success = (result == kIOReturnSuccess)

            DispatchQueue.main.async {
                let formatter = DateFormatter()
                formatter.timeStyle = .medium
                if success {
                    self.lastStatusMessage = "Keyboard lighting updated (\(formatter.string(from: Date())))"
                } else {
                    self.lastStatusMessage = "Command sent (Fallback: Fn + \\ | Fn + Enter)"
                }
            }
        }
    }
}
