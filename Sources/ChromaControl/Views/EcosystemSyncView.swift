import SwiftUI

public struct EcosystemTheme: Identifiable {
    public var id: String { name }
    public let name: String
    public let subtitle: String
    public let icon: String
    public let accentColor: Color
    public let apply: (RazerHardwareManager, AttackSharkManager) -> Void
}

public struct EcosystemSyncView: View {
    @ObservedObject var mouse: RazerHardwareManager
    @ObservedObject var keyboard: AttackSharkManager

    public let themes: [EcosystemTheme] = [
        EcosystemTheme(
            name: "Sith Lord Red",
            subtitle: "Unified aggressive crimson red on both devices",
            icon: "flame.fill",
            accentColor: .red,
            apply: { m, k in
                m.syncAllZones = true
                m.zoneStates[.all] = ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 1.0, green: 0.0, blue: 0.0))
                m.applyCurrentSettings()

                k.selectedEffect = .staticColor
                k.selectedColor = .red
                k.applyLighting()
            }
        ),
        EcosystemTheme(
            name: "Razer Signature Green",
            subtitle: "Esports tournament emerald green ecosystem",
            icon: "shield.fill",
            accentColor: .green,
            apply: { m, k in
                m.syncAllZones = true
                m.zoneStates[.all] = ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 0.0, green: 1.0, blue: 0.2))
                m.applyCurrentSettings()

                k.selectedEffect = .staticColor
                k.selectedColor = .green
                k.applyLighting()
            }
        ),
        EcosystemTheme(
            name: "Cyberpunk 2077",
            subtitle: "Electric yellow mouse with cyan keyboard wave",
            icon: "bolt.fill",
            accentColor: .yellow,
            apply: { m, k in
                m.syncAllZones = false
                m.zoneStates[.scrollWheel] = ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 0.0, green: 0.9, blue: 1.0))
                m.zoneStates[.logo] = ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 1.0, green: 0.85, blue: 0.0))
                m.zoneStates[.underglow] = ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 1.0, green: 0.85, blue: 0.0))
                m.applyCurrentSettings()

                k.selectedEffect = .wave
                k.selectedColor = .cyan
                k.applyLighting()
            }
        ),
        EcosystemTheme(
            name: "Deep Ocean Blue",
            subtitle: "Calming royal blue illumination across desk",
            icon: "water.waves",
            accentColor: Color(red: 0.0, green: 0.4, blue: 1.0),
            apply: { m, k in
                m.syncAllZones = true
                m.zoneStates[.all] = ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 0.0, green: 0.35, blue: 1.0))
                m.applyCurrentSettings()

                k.selectedEffect = .staticColor
                k.selectedColor = .blue
                k.applyLighting()
            }
        ),
        EcosystemTheme(
            name: "Spectrum Wave",
            subtitle: "Synchronized animated rainbow flowing on all gear",
            icon: "rainbow",
            accentColor: .purple,
            apply: { m, k in
                m.syncAllZones = true
                m.zoneStates[.all] = ZoneLightingState(effect: .wave, waveDirection: 1)
                m.applyCurrentSettings()

                k.selectedEffect = .wave
                k.selectedColor = .multi
                k.applyLighting()
            }
        ),
        EcosystemTheme(
            name: "Stealth Blackout",
            subtitle: "Instant shutdown of all mouse and keyboard LEDs",
            icon: "moon.fill",
            accentColor: .gray,
            apply: { m, k in
                m.syncAllZones = true
                m.zoneStates[.all] = ZoneLightingState(effect: .off)
                m.globalBrightness = 0
                m.applyCurrentSettings()

                k.selectedEffect = .off
                k.brightness = 0
                k.applyLighting()
            }
        )
    ]

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Intro header
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "sparkles.rectangle.stack.fill")
                            .foregroundColor(.green)
                        Text("DESK ECOSYSTEM SYNC")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Text("Coordinate your Razer Basilisk V3 mouse and Attack Shark X98 keyboard with matching lighting themes and master brightness.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color(white: 0.08))
                .cornerRadius(12)

                // Master Ecosystem Themes Grid
                VStack(alignment: .leading, spacing: 10) {
                    Text("ONE-CLICK ECOSYSTEM THEMES")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(themes) { theme in
                            Button(action: {
                                theme.apply(mouse, keyboard)
                            }) {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: theme.icon)
                                        .font(.system(size: 20))
                                        .foregroundColor(theme.accentColor)
                                        .frame(width: 28)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(theme.name)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.white)
                                        Text(theme.subtitle)
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()
                                }
                                .padding(12)
                                .background(Color(white: 0.09))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(white: 0.16), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Master Brightness
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(.yellow)
                        Text("MASTER ECOSYSTEM BRIGHTNESS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(mouse.globalBrightness))%")
                            .font(.system(size: 12, design: .monospaced))
                    }

                    Slider(value: $mouse.globalBrightness, in: 0...100, step: 1) { _ in
                        keyboard.brightness = mouse.globalBrightness
                        mouse.applyCurrentSettings()
                        keyboard.applyLighting()
                    }
                    .tint(.green)
                }
                .padding(14)
                .background(Color(white: 0.08))
                .cornerRadius(12)
            }
            .padding(16)
        }
    }
}
