import SwiftUI

public struct KeyboardLightingView: View {
    @ObservedObject var keyboard = AttackSharkManager.shared

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // MARK: - Custom Gamer Preset Highlight Card (User's specific layout)
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(GitHubTheme.dangerRedLight)
                                Text("CUSTOM GAMER LAYOUT: RED & PURPLE")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(GitHubTheme.textPrimary)

                                if keyboard.isCustomMatrixActive {
                                    Text("ACTIVE")
                                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(GitHubTheme.accentGreen.opacity(0.2))
                                        .foregroundColor(GitHubTheme.accentGreenLight)
                                        .cornerRadius(4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(GitHubTheme.accentGreen.opacity(0.4), lineWidth: 1)
                                        )
                                }
                            }

                            Text("Per-key hardware matrix configured directly on the MCU flash:")
                                .font(.system(size: 11))
                                .foregroundColor(GitHubTheme.textSecondary)
                        }

                        Spacer()

                        Button(action: {
                            keyboard.applyGamerRedAndPurplePreset()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "bolt.fill")
                                Text("Apply Red & Purple")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(GitHubTheme.accentGreen)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                            .shadow(color: GitHubTheme.accentGreen.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                    }

                    // Key breakdown visual tags
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(GitHubTheme.dangerRedLight)
                                    .frame(width: 8, height: 8)
                                Text("CRIMSON RED:")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(GitHubTheme.dangerRedLight)
                            }

                            Text("F1–F12 • Esc • Tab • Caps • L/R Shift • L/R Ctrl • L/R Alt • L/R Win • Fn • Enter • Backspace • Arrows • WASD")
                                .font(.system(size: 10))
                                .foregroundColor(GitHubTheme.textPrimary)
                        }

                        HStack(spacing: 8) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(GitHubTheme.accentPurpleLight)
                                    .frame(width: 8, height: 8)
                                Text("VIOLET PURPLE:")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(GitHubTheme.accentPurpleLight)
                            }

                            Text("All remaining keys (Alphanumeric grid, Numpad, and navigation cluster)")
                                .font(.system(size: 10))
                                .foregroundColor(GitHubTheme.textSecondary)
                        }
                    }
                    .padding(10)
                    .background(GitHubTheme.canvasSubtle)
                    .cornerRadius(6)
                }
                .modifier(GitHubCardModifier(padding: 14, cornerRadius: 10))

                // MARK: - Hardware Overview & Connection Info
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "keyboard.fill")
                            .foregroundColor(GitHubTheme.accentGreenLight)
                        Text("ATTACK SHARK X98 MECHANICAL KEYBOARD")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(GitHubTheme.textPrimary)
                        Spacer()
                        Text("VID: 0x1A2C • PID: 0xA034 • Pipe: 0xFF02")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(GitHubTheme.textTertiary)
                    }

                    Text("Direct USB HID communication via macOS IOKit. Commands bypass browser sandbox restrictions to write to the Shinetek keyboard microcontroller.")
                        .font(.system(size: 11))
                        .foregroundColor(GitHubTheme.textSecondary)

                    Divider()
                        .background(GitHubTheme.borderDefault)
                        .padding(.vertical, 2)

                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 12))
                            .foregroundColor(GitHubTheme.accentBlue)

                        Text("Onboard shortcuts (Bluetooth/2.4G wireless fallback): Fn + \\ (Cycle 21 Effects) • Fn + Enter (Cycle 7 Colors) • Fn + ↑/↓ (Brightness) • Fn + ←/→ (Speed)")
                            .font(.system(size: 10))
                            .foregroundColor(GitHubTheme.textSecondary)
                    }
                }
                .modifier(GitHubSubtleCardModifier(padding: 12, cornerRadius: 8))

                // MARK: - Hardware Lighting Effects Grid
                VStack(alignment: .leading, spacing: 10) {
                    Text("HARDWARE LIGHTING MODES")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(GitHubTheme.textSecondary)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: 8)], spacing: 8) {
                        ForEach(KeyboardEffect.allCases) { effect in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    keyboard.selectedEffect = effect
                                    keyboard.applyLighting()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: effect.icon)
                                        .font(.system(size: 13))
                                        .foregroundColor(
                                            keyboard.selectedEffect == effect ?
                                            GitHubTheme.accentGreenLight : GitHubTheme.textSecondary
                                        )
                                        .frame(width: 20)

                                    Text(effect.rawValue)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(
                                            keyboard.selectedEffect == effect ?
                                            GitHubTheme.textPrimary : GitHubTheme.textSecondary
                                        )

                                    Spacer()
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(
                                    keyboard.selectedEffect == effect ?
                                    GitHubTheme.canvasInset : GitHubTheme.canvasSubtle
                                )
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(
                                            keyboard.selectedEffect == effect ?
                                            GitHubTheme.accentGreen : GitHubTheme.borderDefault,
                                            lineWidth: 1
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // MARK: - Primary Color Selector
                VStack(alignment: .leading, spacing: 10) {
                    Text("PRIMARY SOLID COLOR")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(GitHubTheme.textSecondary)

                    HStack(spacing: 12) {
                        ForEach(KeyboardColor.allCases) { color in
                            Button(action: {
                                keyboard.selectedColor = color
                                keyboard.applyLighting()
                            }) {
                                VStack(spacing: 4) {
                                    Circle()
                                        .fill(color.displayColor)
                                        .frame(width: 26, height: 26)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    Color.white,
                                                    lineWidth: keyboard.selectedColor == color && !keyboard.isCustomMatrixActive ? 2 : 0
                                                )
                                        )
                                        .shadow(color: color.displayColor.opacity(0.3), radius: 3, x: 0, y: 2)

                                    Text(color.rawValue.components(separatedBy: " ").last ?? color.rawValue)
                                        .font(.system(size: 9))
                                        .foregroundColor(
                                            keyboard.selectedColor == color && !keyboard.isCustomMatrixActive ?
                                            GitHubTheme.textPrimary : GitHubTheme.textTertiary
                                        )
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .modifier(GitHubCardModifier(padding: 12, cornerRadius: 8))

                // MARK: - Sliders (Brightness & Speed)
                HStack(spacing: 14) {
                    // Brightness
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "sun.max.fill")
                                .foregroundColor(GitHubTheme.warningYellow)
                            Text("BRIGHTNESS")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(GitHubTheme.textSecondary)
                            Spacer()
                            Text("\(Int(keyboard.brightness))%")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(GitHubTheme.textPrimary)
                        }

                        Slider(value: $keyboard.brightness, in: 0...100, step: 25) { _ in
                            if keyboard.isCustomMatrixActive {
                                keyboard.applyGamerRedAndPurplePreset()
                            } else {
                                keyboard.applyLighting()
                            }
                        }
                        .tint(GitHubTheme.accentGreen)
                    }
                    .modifier(GitHubCardModifier(padding: 12, cornerRadius: 8))

                    // Speed
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "gauge.medium")
                                .foregroundColor(GitHubTheme.accentBlue)
                            Text("EFFECT SPEED")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(GitHubTheme.textSecondary)
                            Spacer()
                            Text("\(Int(keyboard.speed))%")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(GitHubTheme.textPrimary)
                        }

                        Slider(value: $keyboard.speed, in: 0...100, step: 25) { _ in
                            keyboard.applyLighting()
                        }
                        .tint(GitHubTheme.accentGreen)
                    }
                    .modifier(GitHubCardModifier(padding: 12, cornerRadius: 8))
                }

                // MARK: - Action Bar
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(keyboard.lastStatusMessage)
                            .font(.system(size: 11))
                            .foregroundColor(GitHubTheme.textSecondary)
                    }

                    Spacer()

                    Button(action: {
                        if keyboard.isCustomMatrixActive {
                            keyboard.applyGamerRedAndPurplePreset()
                        } else {
                            keyboard.applyLighting()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "paperplane.fill")
                            Text("Apply to Keyboard")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(GitHubTheme.accentGreen)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
                .modifier(GitHubSubtleCardModifier(padding: 12, cornerRadius: 8))
            }
            .padding(16)
        }
        .background(GitHubTheme.canvasDefault)
    }
}
