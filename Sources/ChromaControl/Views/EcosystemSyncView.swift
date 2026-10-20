import SwiftUI

public struct EcosystemTheme: Identifiable {
    public var id: String { name }
    public let name: String
    public let subtitle: String
    public let icon: String
    public let accentColor: Color
    public let isRecommended: Bool
    public let apply: (RazerHardwareManager, AttackSharkManager) -> Void

    public init(
        name: String,
        subtitle: String,
        icon: String,
        accentColor: Color,
        isRecommended: Bool = false,
        apply: @escaping (RazerHardwareManager, AttackSharkManager) -> Void
    ) {
        self.name = name
        self.subtitle = subtitle
        self.icon = icon
        self.accentColor = accentColor
        self.isRecommended = isRecommended
        self.apply = apply
    }
}

public struct EcosystemSyncView: View {
    @ObservedObject var mouse: RazerHardwareManager
    @ObservedObject var keyboard: AttackSharkManager

    public let themes: [EcosystemTheme] = [
        EcosystemTheme(
            name: "Gamer Custom: Red & Purple",
            subtitle: "Red accents + Purple underglow on mouse, Per-key Red & Purple matrix on keyboard",
            icon: "sparkles",
            accentColor: GitHubTheme.accentPurpleLight,
            isRecommended: true,
            apply: { m, k in
                // Mouse: Scroll & Logo in Red, Underglow in Purple
                m.syncAllZones = false
                m.zoneStates[.scrollWheel] = ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 1.0, green: 0.0, blue: 0.0))
                m.zoneStates[.logo] = ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 1.0, green: 0.0, blue: 0.0))
                m.zoneStates[.underglow] = ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 0.65, green: 0.0, blue: 1.0))
                m.applyCurrentSettings()

                // Keyboard: Per-key Red on Function/Nav/WASD/Modifiers, Purple on all other keys
                k.applyGamerRedAndPurplePreset()
            }
        ),
        EcosystemTheme(
            name: "Sith Lord Red",
            subtitle: "Unified aggressive crimson red illumination across entire desk",
            icon: "flame.fill",
            accentColor: GitHubTheme.dangerRedLight,
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
            name: "GitHub / Razer Emerald",
            subtitle: "Clean high-contrast developer green across all hardware",
            icon: "terminal.fill",
            accentColor: GitHubTheme.accentGreenLight,
            apply: { m, k in
                m.syncAllZones = true
                m.zoneStates[.all] = ZoneLightingState(effect: .staticColor, primaryColor: Color(red: 0.14, green: 0.75, blue: 0.28))
                m.applyCurrentSettings()

                k.selectedEffect = .staticColor
                k.selectedColor = .green
                k.applyLighting()
            }
        ),
        EcosystemTheme(
            name: "Cyberpunk High Voltage",
            subtitle: "Electric yellow mouse with cyan keyboard wave animation",
            icon: "bolt.fill",
            accentColor: GitHubTheme.warningYellow,
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
            name: "Deep Ocean Horizon",
            subtitle: "Calming royal blue illumination across desk peripherals",
            icon: "water.waves",
            accentColor: GitHubTheme.accentBlue,
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
            name: "Spectrum Cycling",
            subtitle: "Dynamic rainbow wave synchronized on both devices",
            icon: "rainbow",
            accentColor: GitHubTheme.accentPurple,
            apply: { m, k in
                m.syncAllZones = true
                m.zoneStates[.all] = ZoneLightingState(effect: .wave, waveDirection: 1)
                m.applyCurrentSettings()

                k.selectedEffect = .spectrum
                k.applyLighting()
            }
        ),
        EcosystemTheme(
            name: "Stealth Blackout",
            subtitle: "Instant shutdown of all LEDs for distraction-free focus",
            icon: "moon.fill",
            accentColor: GitHubTheme.textTertiary,
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
            VStack(alignment: .leading, spacing: 18) {
                // Intro Header
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "sparkles.rectangle.stack.fill")
                            .foregroundColor(GitHubTheme.accentGreenLight)
                        Text("DESK ECOSYSTEM SYNC")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(GitHubTheme.textPrimary)
                    }
                    Text("Coordinate your Razer Basilisk V3 mouse and Attack Shark X98 keyboard with unified lighting themes and master brightness controls.")
                        .font(.system(size: 11))
                        .foregroundColor(GitHubTheme.textSecondary)
                }
                .modifier(GitHubCardModifier(padding: 14, cornerRadius: 10))

                // Ecosystem Themes Grid
                VStack(alignment: .leading, spacing: 10) {
                    Text("SYNCHRONIZED DESK PRESETS")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(GitHubTheme.textSecondary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(themes) { theme in
                            Button(action: {
                                theme.apply(mouse, keyboard)
                            }) {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: theme.icon)
                                        .font(.system(size: 18))
                                        .foregroundColor(theme.accentColor)
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack(spacing: 6) {
                                            Text(theme.name)
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(GitHubTheme.textPrimary)

                                            if theme.isRecommended {
                                                Text("PRESET")
                                                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                                                    .padding(.horizontal, 4)
                                                    .padding(.vertical, 1)
                                                    .background(GitHubTheme.accentPurple.opacity(0.3))
                                                    .foregroundColor(GitHubTheme.accentPurpleLight)
                                                    .cornerRadius(3)
                                            }
                                        }

                                        Text(theme.subtitle)
                                            .font(.system(size: 10))
                                            .foregroundColor(GitHubTheme.textSecondary)
                                            .lineLimit(2)
                                    }

                                    Spacer()
                                }
                                .padding(12)
                                .background(GitHubTheme.canvasInset)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            theme.isRecommended ?
                                            GitHubTheme.accentPurple.opacity(0.6) : GitHubTheme.borderDefault,
                                            lineWidth: 1
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Master Ecosystem Brightness
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(GitHubTheme.warningYellow)
                        Text("MASTER ECOSYSTEM BRIGHTNESS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(GitHubTheme.textSecondary)
                        Spacer()
                        Text("\(Int(mouse.globalBrightness))%")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(GitHubTheme.textPrimary)
                    }

                    Slider(value: $mouse.globalBrightness, in: 0...100, step: 1) { _ in
                        keyboard.brightness = mouse.globalBrightness
                        mouse.applyCurrentSettings()
                        if keyboard.isCustomMatrixActive {
                            keyboard.applyGamerRedAndPurplePreset()
                        } else {
                            keyboard.applyLighting()
                        }
                    }
                    .tint(GitHubTheme.accentGreen)
                }
                .modifier(GitHubCardModifier(padding: 14, cornerRadius: 10))
            }
            .padding(16)
        }
        .background(GitHubTheme.canvasDefault)
    }
}
