import SwiftUI

public struct KeyboardLightingView: View {
    @ObservedObject var keyboard = AttackSharkManager.shared

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header & Hardware Info Card
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "keyboard.fill")
                            .foregroundColor(.green)
                        Text("ATTACK SHARK X98 RGB CONTROL")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Text("VID: 0x1A2C • PID: 0xA034")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary)
                    }

                    Text("Control all 21 lighting modes, 7 primary colors, brightness, and speeds directly via macOS IOKit USB HID without needing browser WebHID or Windows software.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    Divider()
                        .padding(.vertical, 2)

                    // Hardware limitations banner
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 13))
                            .foregroundColor(.yellow)

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Keyboard Hardware Capabilities & Limitations:")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.yellow)
                            Text("• The X98 uses an integrated Shinetek MCU with 21 internal hardware effects and 7 primary colors. It runs animations natively on-chip rather than streaming raw per-key frames.\n• Direct USB HID commands work when connected via USB-C wired mode.\n• Onboard manual overrides: Fn + \\ (Cycle 21 Effects) • Fn + Enter (Cycle 7 Colors) • Fn + ↑/↓ (Brightness) • Fn + ←/→ (Speed).")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(10)
                    .background(Color.yellow.opacity(0.08))
                    .cornerRadius(8)
                }
                .padding(14)
                .background(Color(white: 0.08))
                .cornerRadius(12)

                // 21 Lighting Effects Grid
                VStack(alignment: .leading, spacing: 10) {
                    Text("KEYBOARD LIGHTING EFFECTS")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
                        ForEach(KeyboardEffect.allCases) { effect in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    keyboard.selectedEffect = effect
                                    keyboard.applyLighting()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: effect.icon)
                                        .font(.system(size: 14))
                                        .foregroundColor(keyboard.selectedEffect == effect ? .black : .green)
                                        .frame(width: 22)

                                    Text(effect.rawValue)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(keyboard.selectedEffect == effect ? .black : .white)

                                    Spacer()
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(
                                    keyboard.selectedEffect == effect ?
                                    Color.green : Color(white: 0.1)
                                )
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(keyboard.selectedEffect == effect ? Color.green : Color(white: 0.18), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // 7 Primary Colors Selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("PRIMARY HARDWARE COLOR")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                        ForEach(KeyboardColor.allCases) { color in
                            Button(action: {
                                keyboard.selectedColor = color
                                keyboard.applyLighting()
                            }) {
                                VStack(spacing: 6) {
                                    Circle()
                                        .fill(color.displayColor)
                                        .frame(width: 28, height: 28)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: keyboard.selectedColor == color ? 2.5 : 0)
                                        )
                                        .shadow(color: color.displayColor.opacity(0.4), radius: 4, x: 0, y: 2)

                                    Text(color.rawValue.components(separatedBy: " ").last ?? color.rawValue)
                                        .font(.system(size: 10))
                                        .foregroundColor(keyboard.selectedColor == color ? .white : .secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(14)
                .background(Color(white: 0.08))
                .cornerRadius(12)

                // Brightness & Animation Speed Sliders
                HStack(spacing: 16) {
                    // Brightness
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "sun.max.fill")
                                .foregroundColor(.yellow)
                            Text("BRIGHTNESS")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(keyboard.brightness))%")
                                .font(.system(size: 12, design: .monospaced))
                        }

                        Slider(value: $keyboard.brightness, in: 0...100, step: 25) { _ in
                            keyboard.applyLighting()
                        }
                        .tint(.green)
                    }
                    .padding(14)
                    .background(Color(white: 0.08))
                    .cornerRadius(12)

                    // Speed
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "gauge.medium")
                                .foregroundColor(.green)
                            Text("EFFECT SPEED")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(keyboard.speed))%")
                                .font(.system(size: 12, design: .monospaced))
                        }

                        Slider(value: $keyboard.speed, in: 0...100, step: 25) { _ in
                            keyboard.applyLighting()
                        }
                        .tint(.green)
                    }
                    .padding(14)
                    .background(Color(white: 0.08))
                    .cornerRadius(12)
                }

                // Action Bar
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(keyboard.lastStatusMessage)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(action: {
                        keyboard.applyLighting()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "paperplane.fill")
                            Text("Apply to Keyboard")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(10)
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
}
