import SwiftUI

public enum LightingZone: String, CaseIterable, Identifiable {
    case all = "All Zones (Sync)"
    case scrollWheel = "Scroll Wheel"
    case logo = "Razer Logo"
    case underglow = "Underglow / Base"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .all: return "sparkles"
        case .scrollWheel: return "computermouse"
        case .logo: return "shield.checkered"
        case .underglow: return "glow"
        }
    }
}
