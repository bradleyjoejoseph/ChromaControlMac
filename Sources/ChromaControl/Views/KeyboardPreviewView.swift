import SwiftUI

public struct KeyboardPreviewView: View {
    @ObservedObject var keyboard = AttackSharkManager.shared
    @ObservedObject var ui = UIStateManager.shared

    private var activeColor: Color {
        switch keyboard.selectedEffect {
        case .staticColor, .breathing, .ripple, .raindrop, .reactive, .sineWave, .laser:
            return keyboard.selectedColor.displayColor
        case .wave, .spectrum, .aurora, .vortex, .snake:
            return Color(hue: Double(ui.previewPhase).truncatingRemainder(dividingBy: 1.0), saturation: 0.95, brightness: 1.0)
        case .off, .shadows:
            return Color.black.opacity(0.15)
        }
    }

    private var glowOpacity: Double {
        if keyboard.selectedEffect == .breathing {
            return ui.breathingOpacity * (keyboard.brightness / 100.0)
        }
        if keyboard.selectedEffect == .off {
            return 0.05
        }
        return (keyboard.brightness / 100.0)
    }

    public var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Background Ambient Glow
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        RadialGradient(
                            colors: [activeColor.opacity(0.20 * glowOpacity), Color.clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 180
                        )
                    )
                    .frame(width: 320, height: 200)

                // Keyboard Case / Frame (98-key layout proportion)
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color(white: 0.16), Color(white: 0.09)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(white: 0.25), lineWidth: 1.5)
                        )
                        .shadow(color: .black.opacity(0.8), radius: 12, x: 0, y: 8)
                        .frame(width: 290, height: 130)

                    // Top plate accent
                    VStack(spacing: 3) {
                        // Function Row
                        KeyRow(count: 16, height: 10, color: activeColor, opacity: glowOpacity, phase: ui.previewPhase)

                        // Number Row
                        KeyRow(count: 16, height: 12, color: activeColor, opacity: glowOpacity, phase: ui.previewPhase + 0.1)

                        // QWERTY Row
                        KeyRow(count: 15, height: 12, color: activeColor, opacity: glowOpacity, phase: ui.previewPhase + 0.2)

                        // ASDF Row
                        KeyRow(count: 15, height: 12, color: activeColor, opacity: glowOpacity, phase: ui.previewPhase + 0.3)

                        // ZXCV Row
                        KeyRow(count: 14, height: 12, color: activeColor, opacity: glowOpacity, phase: ui.previewPhase + 0.4)

                        // Spacebar + Nav Row
                        HStack(spacing: 3) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(white: 0.15))
                                .frame(width: 16, height: 12)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(white: 0.15))
                                .frame(width: 16, height: 12)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(white: 0.15))
                                .frame(width: 16, height: 12)

                            // Spacebar with South-Facing RGB Glow
                            ZStack {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(activeColor.opacity(0.8 * glowOpacity))
                                    .frame(width: 90, height: 12)
                                    .blur(radius: 2)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(activeColor.opacity(glowOpacity))
                                    .frame(width: 86, height: 10)
                            }

                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(white: 0.15))
                                .frame(width: 16, height: 12)

                            // Arrow cluster + Numpad hints
                            ForEach(0..<4) { _ in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(activeColor.opacity(0.7 * glowOpacity))
                                    .frame(width: 14, height: 12)
                            }
                        }
                    }
                    .padding(8)
                }
            }
            .frame(height: 180)

            // Keyboard specs badge
            HStack(spacing: 6) {
                Circle()
                    .fill(keyboard.isConnected ? Color.green : Color.orange)
                    .frame(width: 6, height: 6)
                Text(keyboard.isConnected ? "USB HID Ready (0xFF02)" : "Hardware Shortcuts Active")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct KeyRow: View {
    let count: Int
    let height: CGFloat
    let color: Color
    let opacity: Double
    let phase: CGFloat

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<count, id: \.self) { i in
                let keyColor = color
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(keyColor.opacity(0.85 * opacity))
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                        .blur(radius: 1.5)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(keyColor.opacity(opacity))
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                }
            }
        }
        .frame(width: 270)
    }
}
