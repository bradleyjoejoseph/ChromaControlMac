import SwiftUI

public struct PresetProfile: Identifiable {
    public var id: String { name }
    public let name: String
    public let subtitle: String
    public let icon: String
    public let accentColor: Color
    public let setup: (RazerHardwareManager) -> Void
}

public struct ProfilesView: View {
    @ObservedObject var hardware: RazerHardwareManager

    public let profiles: [PresetProfile] = [
        PresetProfile(
            name: "Sith Lord Red",
            subtitle: "Aggressive pure crimson red on all zones",
            icon: "flame.fill",
            accentColor: Color.red,
            setup: { hw in
                hw.syncAllZones = true
                hw.globalBrightness = 100
                hw.zoneStates[.all] = ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 1.0, green: 0.0, blue: 0.0))
            }
        ),
        PresetProfile(
            name: "Razer Signature Green",
            subtitle: "The classic esports tournament look",
            icon: "shield.fill",
            accentColor: Color.green,
            setup: { hw in
                hw.syncAllZones = true
                hw.globalBrightness = 100
                hw.zoneStates[.all] = ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 0.0, green: 1.0, blue: 0.2))
            }
        ),
        PresetProfile(
            name: "Cyberpunk 2077",
            subtitle: "Electric yellow base with neon cyan wheel",
            icon: "bolt.horizontal.fill",
            accentColor: Color.yellow,
            setup: { hw in
                hw.syncAllZones = false
                hw.globalBrightness = 100
                hw.zoneStates[.scrollWheel] = ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 0.0, green: 0.9, blue: 1.0))
                hw.zoneStates[.logo] = ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 1.0, green: 0.85, blue: 0.0))
                hw.zoneStates[.underglow] = ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 1.0, green: 0.85, blue: 0.0))
            }
        ),
        PresetProfile(
            name: "Vaporwave Synth",
            subtitle: "Hot pink logo with purple underglow",
            icon: "waveform.circle.fill",
            accentColor: Color(red: 1.0, green: 0.0, blue: 0.6),
            setup: { hw in
                hw.syncAllZones = false
                hw.globalBrightness = 100
                hw.zoneStates[.scrollWheel] = ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 0.0, green: 0.8, blue: 1.0))
                hw.zoneStates[.logo] = ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 1.0, green: 0.0, blue: 0.6))
                hw.zoneStates[.underglow] = ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 0.6, green: 0.0, blue: 1.0))
            }
        ),
        PresetProfile(
            name: "Spectrum Wave",
            subtitle: "Continuous rainbow ripple across all 11 zones",
            icon: "rainbow",
            accentColor: Color.blue,
            setup: { hw in
                hw.syncAllZones = true
                hw.globalBrightness = 100
                hw.zoneStates[.all] = ZoneLightingState(effect: .wave, waveDirection: 1)
            }
        ),
        PresetProfile(
            name: "Stealth Blackout",
            subtitle: "Zero lighting for focused work or dark rooms",
            icon: "moon.fill",
            accentColor: Color.gray,
            setup: { hw in
                hw.syncAllZones = true
                hw.globalBrightness = 0
                hw.zoneStates[.all] = ZoneLightingState(effect: .off)
            }
        )
    ]

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("QUICK PROFILES")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(profiles) { profile in
                        Button(action: {
                            profile.setup(hardware)
                            hardware.applyCurrentSettings()
                        }) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: profile.icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(profile.accentColor)
                                    .frame(width: 30)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(profile.name)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                    Text(profile.subtitle)
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()
                            }
                            .padding(14)
                            .background(Color(white: 0.09))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(white: 0.16), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
        }
    }
}
