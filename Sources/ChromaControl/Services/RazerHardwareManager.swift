import Foundation
import SwiftUI
import AppKit
import CRazerDriver

public extension Color {
    func toRGB() -> (r: UInt8, g: UInt8, b: UInt8) {
        let nsColor = NSColor(self).usingColorSpace(.sRGB) ?? NSColor.red
        let r = UInt8(max(0, min(255, (nsColor.redComponent * 255.0).rounded())))
        let g = UInt8(max(0, min(255, (nsColor.greenComponent * 255.0).rounded())))
        let b = UInt8(max(0, min(255, (nsColor.blueComponent * 255.0).rounded())))
        return (r, g, b)
    }

    init(hex: String) {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanHex.hasPrefix("#") { cleanHex.removeFirst() }
        var rgbValue: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&rgbValue)
        let r = Double((rgbValue >> 16) & 0xFF) / 255.0
        let g = Double((rgbValue >> 8) & 0xFF) / 255.0
        let b = Double(rgbValue & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

public class RazerHardwareManager: ObservableObject {
    public static let shared = RazerHardwareManager()

    @Published public var isConnected: Bool = false
    @Published public var deviceName: String = "Searching for Razer mouse..."
    @Published public var productId: UInt16 = 0
    @Published public var syncAllZones: Bool = true
    @Published public var selectedZone: LightingZone = .all
    @Published public var globalBrightness: Double = 100.0
    @Published public var currentDpi: Int = 1600
    @Published public var pollingRate: Int = 1000
    @Published public var saveToOnboardMemory: Bool = true
    @Published public var lastStatusMessage: String = "Ready"

    @Published public var zoneStates: [LightingZone: ZoneLightingState] = [
        .all: ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 1.0, green: 0.0, blue: 0.0)),
        .scrollWheel: ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 1.0, green: 0.0, blue: 0.0)),
        .logo: ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 1.0, green: 0.0, blue: 0.0)),
        .underglow: ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 1.0, green: 0.0, blue: 0.0))
    ]

    private var pollTimer: Timer?
    private let queue = DispatchQueue(label: "com.antigravity.razer.hardware", qos: .userInitiated)

    public init() {
        refreshDevices()
        startPolling()
    }

    deinit {
        pollTimer?.invalidate()
    }

    public func startPolling() {
        pollTimer?.invalidate()
        pollTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
            self?.refreshDevices()
        }
    }

    public func refreshDevices() {
        queue.async {
            let allDevices = getAllRazerDevices()
            defer { closeAllRazerDevices(allDevices) }

            var found = false
            var foundPid: UInt16 = 0
            var name = "No Device Detected"

            for i in 0..<Int(allDevices.size) {
                let dev = allDevices.devices[i]
                if dev.productId == 0x0099 || dev.productId == 0x00AA || dev.productId == 0x0085 {
                    found = true
                    foundPid = dev.productId
                    name = RazerDeviceModel.nameFor(productId: dev.productId)
                    break
                }
            }

            DispatchQueue.main.async {
                self.isConnected = found
                self.productId = foundPid
                self.deviceName = name
                if found && self.lastStatusMessage == "Searching for Razer mouse..." {
                    self.lastStatusMessage = "Connected: \(name)"
                }
            }
        }
    }

    public func applyCurrentSettings() {
        let sync = self.syncAllZones
        let targetZone = self.selectedZone
        let states = self.zoneStates
        let brightness = UInt8(max(0, min(100, self.globalBrightness)))
        let dpi = UInt16(self.currentDpi)
        let rate = UInt16(self.pollingRate)

        queue.async {
            let allDevices = getAllRazerDevices()
            defer { closeAllRazerDevices(allDevices) }

            for i in 0..<Int(allDevices.size) {
                let dev = allDevices.devices[i]
                guard dev.productId == 0x0099 || dev.productId == 0x00AA || dev.productId == 0x0085 else { continue }
                guard let usb = dev.usbDevice else { continue }

                // 1. Set Brightness
                razer_attr_write_matrix_brightness(usb, brightness)
                razer_attr_write_scroll_led_brightness(usb, brightness)
                razer_attr_write_logo_led_brightness(usb, brightness)
                razer_attr_write_left_led_brightness(usb, brightness)
                razer_attr_write_right_led_brightness(usb, brightness)
                usleep(15000)

                // 2. Set DPI and Poll rate
                razer_attr_write_dpi(usb, dpi, dpi)
                usleep(10000)
                razer_attr_write_poll_rate(usb, rate)
                usleep(10000)

                // 3. Set Lighting Zones
                if sync {
                    let masterState = states[.all] ?? ZoneLightingState()
                    self.applyEffect(masterState, toZone: .scrollWheel, usb: usb)
                    self.applyEffect(masterState, toZone: .logo, usb: usb)
                    self.applyEffect(masterState, toZone: .underglow, usb: usb)
                } else {
                    if targetZone == .all {
                        if let s = states[.scrollWheel] { self.applyEffect(s, toZone: .scrollWheel, usb: usb) }
                        if let s = states[.logo] { self.applyEffect(s, toZone: .logo, usb: usb) }
                        if let s = states[.underglow] { self.applyEffect(s, toZone: .underglow, usb: usb) }
                    } else {
                        if let s = states[targetZone] {
                            self.applyEffect(s, toZone: targetZone, usb: usb)
                        }
                    }
                }
            }

            DispatchQueue.main.async {
                let formatter = DateFormatter()
                formatter.timeStyle = .medium
                self.lastStatusMessage = "Settings saved & applied (\(formatter.string(from: Date())))"
            }
        }
    }

    private func applyEffect(_ state: ZoneLightingState, toZone zone: LightingZone, usb: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>) {
        let (r, g, b) = state.primaryColor.toRGB()
        var rgbBytes: [CChar] = [CChar(bitPattern: r), CChar(bitPattern: g), CChar(bitPattern: b)]

        switch state.effect {
        case .staticColor:
            switch zone {
            case .scrollWheel:
                razer_attr_write_scroll_mode_static(usb, &rgbBytes, 3)
            case .logo:
                razer_attr_write_logo_mode_static(usb, &rgbBytes, 3)
            case .underglow, .all:
                razer_attr_write_left_mode_static(usb, &rgbBytes, 3)
                razer_attr_write_right_mode_static(usb, &rgbBytes, 3)
            }

        case .spectrum:
            switch zone {
            case .scrollWheel:
                razer_attr_write_scroll_mode_spectrum(usb, "1", 1)
            case .logo:
                razer_attr_write_logo_mode_spectrum(usb, "1", 1)
            case .underglow, .all:
                razer_attr_write_left_mode_spectrum(usb, "1", 1)
                razer_attr_write_right_mode_spectrum(usb, "1", 1)
            }

        case .wave:
            let dir = state.waveDirection == 1 ? "1" : "2"
            switch zone {
            case .scrollWheel:
                razer_attr_write_scroll_mode_wave(usb, dir, 1)
            case .logo:
                razer_attr_write_logo_mode_wave(usb, dir, 1)
            case .underglow, .all:
                razer_attr_write_left_mode_wave(usb, dir, 1)
                razer_attr_write_right_mode_wave(usb, dir, 1)
            }

        case .breathing:
            if state.breathingMode == 0 {
                // Single color
                switch zone {
                case .scrollWheel:
                    razer_attr_write_scroll_mode_breath(usb, &rgbBytes, 3)
                case .logo:
                    razer_attr_write_logo_mode_breath(usb, &rgbBytes, 3)
                case .underglow, .all:
                    razer_attr_write_left_mode_breath(usb, &rgbBytes, 3)
                    razer_attr_write_right_mode_breath(usb, &rgbBytes, 3)
                }
            } else if state.breathingMode == 1 {
                // Dual color
                let (r2, g2, b2) = state.secondaryColor.toRGB()
                var dualBytes: [CChar] = [
                    CChar(bitPattern: r), CChar(bitPattern: g), CChar(bitPattern: b),
                    CChar(bitPattern: r2), CChar(bitPattern: g2), CChar(bitPattern: b2)
                ]
                switch zone {
                case .scrollWheel:
                    razer_attr_write_scroll_mode_breath(usb, &dualBytes, 6)
                case .logo:
                    razer_attr_write_logo_mode_breath(usb, &dualBytes, 6)
                case .underglow, .all:
                    razer_attr_write_left_mode_breath(usb, &dualBytes, 6)
                    razer_attr_write_right_mode_breath(usb, &dualBytes, 6)
                }
            } else {
                // Random
                var empty: [CChar] = [0]
                switch zone {
                case .scrollWheel:
                    razer_attr_write_scroll_mode_breath(usb, &empty, 0)
                case .logo:
                    razer_attr_write_logo_mode_breath(usb, &empty, 0)
                case .underglow, .all:
                    razer_attr_write_left_mode_breath(usb, &empty, 0)
                    razer_attr_write_right_mode_breath(usb, &empty, 0)
                }
            }

        case .reactive:
            var reactBytes: [CChar] = [CChar(state.reactiveSpeed), CChar(bitPattern: r), CChar(bitPattern: g), CChar(bitPattern: b)]
            switch zone {
            case .scrollWheel:
                razer_attr_write_scroll_mode_reactive(usb, &reactBytes, 4)
            case .logo:
                razer_attr_write_logo_mode_reactive(usb, &reactBytes, 4)
            case .underglow, .all:
                razer_attr_write_left_mode_reactive(usb, &reactBytes, 4)
                razer_attr_write_right_mode_reactive(usb, &reactBytes, 4)
            }

        case .off:
            var empty: [CChar] = [0]
            switch zone {
            case .scrollWheel:
                razer_attr_write_scroll_mode_none(usb, &empty, 1)
            case .logo:
                razer_attr_write_logo_mode_none(usb, &empty, 1)
            case .underglow, .all:
                razer_attr_write_left_mode_none(usb, &empty, 1)
                razer_attr_write_right_mode_none(usb, &empty, 1)
            }
        }

        usleep(20000)
    }
}
