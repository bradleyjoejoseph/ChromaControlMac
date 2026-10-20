import SwiftUI

public struct LightingView: View {
    @ObservedObject var hardware: RazerHardwareManager

    private var currentZoneState: Binding<ZoneLightingState> {
        let key = hardware.syncAllZones ? .all : hardware.selectedZone
        return Binding<ZoneLightingState>(
            get: { hardware.zoneStates[key] ?? ZoneLightingState() },
            set: { hardware.zoneStates[key] = $0 }
        )
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Zone Sync Switcher
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("LIGHTING ZONES")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(GitHubTheme.textSecondary)
                        Text(hardware.syncAllZones ? "All Zones Synchronized" : "Customizing: \(hardware.selectedZone.rawValue)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(GitHubTheme.textPrimary)
                    }

                    Spacer()

                    Toggle("Sync All Zones", isOn: $hardware.syncAllZones)
                        .toggleStyle(.switch)
                        .tint(GitHubTheme.accentGreen)
                }
                .modifier(GitHubCardModifier(padding: 14, cornerRadius: 10))

                // Effects Grid
                VStack(alignment: .leading, spacing: 10) {
                    Text("CHROMA EFFECTS")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(GitHubTheme.textSecondary)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: 8)], spacing: 8) {
                        ForEach(LightingEffectType.allCases) { effect in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    currentZoneState.wrappedValue.effect = effect
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: effect.icon)
                                        .font(.system(size: 14))
                                        .foregroundColor(
                                            currentZoneState.wrappedValue.effect == effect ?
                                            GitHubTheme.accentGreenLight : GitHubTheme.textSecondary
                                        )
                                        .frame(width: 20)

                                    Text(effect.rawValue)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(
                                            currentZoneState.wrappedValue.effect == effect ?
                                            GitHubTheme.textPrimary : GitHubTheme.textSecondary
                                        )

                                    Spacer()
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(
                                    currentZoneState.wrappedValue.effect == effect ?
                                    GitHubTheme.canvasInset : GitHubTheme.canvasSubtle
                                )
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(
                                            currentZoneState.wrappedValue.effect == effect ?
                                            GitHubTheme.accentGreen : GitHubTheme.borderDefault,
                                            lineWidth: 1
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Effect Settings Panel
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: currentZoneState.wrappedValue.effect.icon)
                            .foregroundColor(GitHubTheme.accentGreenLight)
                        Text(currentZoneState.wrappedValue.effect.rawValue.uppercased() + " SETTINGS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(GitHubTheme.textPrimary)
                    }

                    Text(currentZoneState.wrappedValue.effect.description)
                        .font(.system(size: 11))
                        .foregroundColor(GitHubTheme.textSecondary)

                    switch currentZoneState.wrappedValue.effect {
                    case .staticColor:
                        ColorPickerView(selectedColor: currentZoneState.primaryColor)

                    case .breathing:
                        VStack(alignment: .leading, spacing: 12) {
                            Picker("Breathing Mode", selection: currentZoneState.breathingMode) {
                                Text("Single Color").tag(0)
                                Text("Dual Color").tag(1)
                                Text("Random Spectrum").tag(2)
                            }
                            .pickerStyle(.segmented)

                            if currentZoneState.wrappedValue.breathingMode == 0 {
                                ColorPickerView(selectedColor: currentZoneState.primaryColor)
                            } else if currentZoneState.wrappedValue.breathingMode == 1 {
                                Text("Primary Color")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(GitHubTheme.textSecondary)
                                ColorPickerView(selectedColor: currentZoneState.primaryColor)

                                Text("Secondary Color")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(GitHubTheme.textSecondary)
                                ColorPickerView(selectedColor: currentZoneState.secondaryColor)
                            }
                        }

                    case .wave:
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Direction")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(GitHubTheme.textSecondary)
                            Picker("Direction", selection: currentZoneState.waveDirection) {
                                Text("Forward (Top to Bottom)").tag(1)
                                Text("Reverse (Bottom to Top)").tag(2)
                            }
                            .pickerStyle(.segmented)
                        }

                    case .reactive:
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Reactive Duration")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(GitHubTheme.textSecondary)
                                Spacer()
                                Text(reactiveDurationText(currentZoneState.wrappedValue.reactiveSpeed))
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(GitHubTheme.accentGreenLight)
                            }

                            Slider(value: Binding(
                                get: { Double(currentZoneState.wrappedValue.reactiveSpeed) },
                                set: { currentZoneState.wrappedValue.reactiveSpeed = Int($0) }
                            ), in: 1...4, step: 1)
                            .tint(GitHubTheme.accentGreen)

                            ColorPickerView(selectedColor: currentZoneState.primaryColor)
                        }

                    case .spectrum:
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(GitHubTheme.accentGreenLight)
                            Text("Cycles smoothly across all 16.8 million Razer Chroma colors.")
                                .font(.system(size: 12))
                                .foregroundColor(GitHubTheme.textSecondary)
                        }
                        .padding(.vertical, 4)

                    case .off:
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(GitHubTheme.textTertiary)
                            Text("LEDs disabled for zero distraction / stealth gaming.")
                                .font(.system(size: 12))
                                .foregroundColor(GitHubTheme.textSecondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .modifier(GitHubCardModifier(padding: 14, cornerRadius: 10))

                // Brightness Slider
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(GitHubTheme.warningYellow)
                        Text("CHROMA BRIGHTNESS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(GitHubTheme.textSecondary)
                        Spacer()
                        Text("\(Int(hardware.globalBrightness))%")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(GitHubTheme.textPrimary)
                    }

                    Slider(value: $hardware.globalBrightness, in: 0...100, step: 1)
                        .tint(GitHubTheme.accentGreen)
                }
                .modifier(GitHubCardModifier(padding: 12, cornerRadius: 8))

                // Action Bar
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Toggle("Save to Onboard Flash (VARSTORE)", isOn: $hardware.saveToOnboardMemory)
                            .toggleStyle(.checkbox)
                            .font(.system(size: 11))
                            .foregroundColor(GitHubTheme.textPrimary)
                        Text("Settings persist across machine reboots and disconnections")
                            .font(.system(size: 10))
                            .foregroundColor(GitHubTheme.textSecondary)
                    }

                    Spacer()

                    Button(action: {
                        hardware.applyCurrentSettings()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "paperplane.fill")
                            Text("Apply to Mouse")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(GitHubTheme.accentGreen)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                        .shadow(color: GitHubTheme.accentGreen.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
                .modifier(GitHubSubtleCardModifier(padding: 12, cornerRadius: 8))
            }
            .padding(16)
        }
        .background(GitHubTheme.canvasDefault)
    }

    private func reactiveDurationText(_ speed: Int) -> String {
        switch speed {
        case 1: return "Short (1s)"
        case 2: return "Medium (2s)"
        case 3: return "Long (3s)"
        case 4: return "Ultra Long (4s)"
        default: return "Medium"
        }
    }
}
