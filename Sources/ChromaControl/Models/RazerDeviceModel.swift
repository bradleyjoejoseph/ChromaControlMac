import Foundation

public struct RazerDeviceModel: Identifiable, Equatable {
    public var id: String { String(format: "0x%04X", productId) }
    public var name: String
    public var productId: UInt16
    public var vendorId: UInt16
    public var isConnected: Bool
    public var isWired: Bool

    public static func nameFor(productId: UInt16) -> String {
        switch productId {
        case 0x0099: return "Razer Basilisk V3"
        case 0x00AA: return "Razer Basilisk V3 Pro (Wired)"
        case 0x00AB: return "Razer Basilisk V3 Pro (Wireless)"
        case 0x0085: return "Razer Basilisk V2"
        case 0x0064: return "Razer Basilisk"
        case 0x0084: return "Razer DeathAdder V2"
        case 0x007C: return "Razer DeathAdder V2 Pro"
        case 0x0078: return "Razer Viper"
        case 0x007A: return "Razer Viper Ultimate"
        case 0x006C: return "Razer Mamba Elite"
        case 0x0067: return "Razer Naga Trinity"
        default: return String(format: "Razer Device (0x%04X)", productId)
        }
    }
}
