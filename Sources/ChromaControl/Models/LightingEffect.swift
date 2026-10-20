import SwiftUI

public enum LightingEffectType: String, CaseIterable, Identifiable {
    case staticColor = "Static"
    case breathing = "Breathing"
    case spectrum = "Spectrum Cycling"
    case wave = "Wave"
    case reactive = "Reactive"
    case off = "Off / None"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .staticColor: return "sun.max.fill"
        case .breathing: return "wind"
        case .spectrum: return "rainbow"
        case .wave: return "water.waves"
        case .reactive: return "bolt.fill"
        case .off: return "moon.stars"
        }
    }

    public var description: String {
        switch self {
        case .staticColor: return "Keeps your mouse illuminated in a single solid color."
        case .breathing: return "Gently fades between brightness levels or colors."
        case .spectrum: return "Seamlessly cycles through the entire 16.8 million color spectrum."
        case .wave: return "Animates a moving rainbow across all lighting zones."
        case .reactive: return "Illuminates upon clicking or moving and fades away."
        case .off: return "Turns all mouse LEDs completely off for stealth mode."
        }
    }
}

public struct ZoneLightingState: Equatable {
    public var effect: LightingEffectType
    public var primaryColor: Color
    public var secondaryColor: Color
    public var breathingMode: Int // 0: single, 1: dual, 2: random
    public var waveDirection: Int // 1: forward, 2: reverse
    public var reactiveSpeed: Int // 1 to 4
    public var brightness: Double // 0 to 100

    public init(
        effect: LightingEffectType = .staticColor,
        primaryColor: Color = Color(red: 1.0, green: 0.0, blue: 0.0), // Default Red
        secondaryColor: Color = Color(red: 0.0, green: 1.0, blue: 0.33),
        breathingMode: Int = 0,
        waveDirection: Int = 1,
        reactiveSpeed: Int = 2,
        brightness: Double = 100.0
    ) {
        self.effect = effect
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.breathingMode = breathingMode
        self.waveDirection = waveDirection
        self.reactiveSpeed = reactiveSpeed
        self.brightness = brightness
    }
}
