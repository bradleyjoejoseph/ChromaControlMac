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
            VStack(alignment: .leading, spacing: 20) {
                // Zone Sync Switcher
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("LIGHTING ZONES")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)
                        Text(hardware.syncAllZones ? "All Zones Synchronized" : "Customizing: \(hardware.selectedZone.rawValue)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Toggle("Sync All Zones", isOn: $hardware.syncAllZones)
                        .toggleStyle(.switch)
                        .tint(.green)
                }
                .padding(14)
                .background(Color(white: 0.08))
                .cornerRadius(12)

                // Effects Grid
                VStack(alignment: .leading, spacing: 10) {
                    Text("CHROMA EFFECTS")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
                        ForEach(LightingEffectType.allCases) { effect in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    currentZoneState.wrappedValue.effect = effect
                                }
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: effect.icon)
                                        .font(.system(size: 16))
                                        .foregroundColor(currentZoneState.wrappedValue.effect == effect ? .black : .green)
                                        .frame(width: 24)

                                    Text(effect.rawValue)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(currentZoneState.wrappedValue.effect == effect ? .black : .white)

                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(
                                    currentZoneState.wrappedValue.effect == effect ?
                                    Color.green : Color(white: 0.1)
                                )
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(currentZoneState.wrappedValue.effect == effect ? Color.green : Color(white: 0.18), lineWidth: 1)
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
                            .foregroundColor(.green)
                        Text(currentZoneState.wrappedValue.effect.rawValue.uppercased() + " SETTINGS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Text(currentZoneState.wrappedValue.effect.description)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)

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
                                ColorPickerView(selectedColor: currentZoneState.primaryColor)

                                Text("Secondary Color")
                                    .font(.system(size: 11, weight: .semibold))
                                ColorPickerView(selectedColor: currentZoneState.secondaryColor)
                            }
                        }

                    case .wave:
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Direction")
                                .font(.system(size: 12, weight: .medium))
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
                                    .font(.system(size: 12, weight: .medium))
                                Spacer()
                                Text(reactiveDurationText(currentZoneState.wrappedValue.reactiveSpeed))
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(.green)
                            }

                            Slider(value: Binding(
                                get: { Double(currentZoneState.wrappedValue.reactiveSpeed) },
                                set: { currentZoneState.wrappedValue.reactiveSpeed = Int($0) }
                            ), in: 1...4, step: 1)
                            .tint(.green)

                            ColorPickerView(selectedColor: currentZoneState.primaryColor)
                        }

                    case .spectrum:
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Cycles through all 16.8 million Chroma colors dynamically.")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)

                    case .off:
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.gray)
                            Text("LEDs disabled for zero distraction / stealth gaming.")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding(14)
                .background(Color(white: 0.08))
                .cornerRadius(12)

                // Brightness Slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(.yellow)
                        Text("CHROMA BRIGHTNESS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(hardware.globalBrightness))%")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }

                    Slider(value: $hardware.globalBrightness, in: 0...100, step: 1)
                        .tint(.green)
                }
                .padding(14)
                .background(Color(white: 0.08))
                .cornerRadius(12)

                // Action Bar
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Toggle("Save to Onboard Memory", isOn: $hardware.saveToOnboardMemory)
                            .toggleStyle(.checkbox)
                            .font(.system(size: 12))
                        Text("Settings will persist without software running")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(action: {
                        hardware.applyCurrentSettings()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "paperplane.fill")
                            Text("Apply to Mouse")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .shadow(color: Color.green.opacity(0.4), radius: 8, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                }
                .padding(14)
                .background(Color(white: 0.06))
                .cornerRadius(12)
            }
            .padding(16)
        }
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
