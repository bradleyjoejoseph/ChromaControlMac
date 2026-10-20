import SwiftUI

public struct KeyboardPreviewView: View {
    @ObservedObject var keyboard = AttackSharkManager.shared
    @ObservedObject var ui = UIStateManager.shared

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
                let primaryColor = keyboard.isCustomMatrixActive ? GitHubTheme.accentPurpleLight : activeColorForEffect
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        RadialGradient(
                            colors: [primaryColor.opacity(0.18 * glowOpacity), Color.clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 160
                        )
                    )
                    .frame(width: 310, height: 180)

                // Keyboard Case / Frame (98-key layout proportion)
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(GitHubTheme.canvasSubtle)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(GitHubTheme.borderDefault, lineWidth: 1.5)
                        )
                        .shadow(color: .black.opacity(0.7), radius: 10, x: 0, y: 6)
                        .frame(width: 292, height: 132)

                    // Keyboard Key Matrix Simulation
                    VStack(spacing: 3) {
                        // Function Row: Esc (RED), F1-F12 (RED), Del/Pause
                        FunctionRowView(
                            isCustom: keyboard.isCustomMatrixActive,
                            fallbackColor: activeColorForEffect,
                            opacity: glowOpacity
                        )

                        // Number Row: `~, 1-0, -, =, Backspace (RED)
                        NumberRowView(
                            isCustom: keyboard.isCustomMatrixActive,
                            fallbackColor: activeColorForEffect,
                            opacity: glowOpacity
                        )

                        // QWERTY Row: Tab (RED), Q, W (RED), E, R, T, Y, U, I, O, P, [, ], \
                        QwertyRowView(
                            isCustom: keyboard.isCustomMatrixActive,
                            fallbackColor: activeColorForEffect,
                            opacity: glowOpacity
                        )

                        // Home Row: Caps (RED), A (RED), S (RED), D (RED), F, G, H, J, K, L, ;, ', Enter (RED)
                        HomeRowView(
                            isCustom: keyboard.isCustomMatrixActive,
                            fallbackColor: activeColorForEffect,
                            opacity: glowOpacity
                        )

                        // Shift Row: LShift (RED), Z, X, C, V, B, N, M, ,, ., /, RShift (RED), Up (RED)
                        ShiftRowView(
                            isCustom: keyboard.isCustomMatrixActive,
                            fallbackColor: activeColorForEffect,
                            opacity: glowOpacity
                        )

                        // Bottom Row: LCtrl (RED), LWin (RED), LAlt (RED), Space, RAlt (RED), Fn (RED), RCtrl (RED), Left (RED), Down (RED), Right (RED)
                        BottomRowView(
                            isCustom: keyboard.isCustomMatrixActive,
                            fallbackColor: activeColorForEffect,
                            opacity: glowOpacity
                        )
                    }
                    .padding(8)
                }
            }
            .frame(height: 160)

            // Status Badge
            HStack(spacing: 6) {
                Circle()
                    .fill(keyboard.isConnected ? GitHubTheme.accentGreenLight : GitHubTheme.warningYellow)
                    .frame(width: 6, height: 6)
                Text(
                    keyboard.isCustomMatrixActive ?
                    "Custom Red & Purple Matrix" :
                    (keyboard.isConnected ? "Attack Shark X98 (0xFF02)" : "Shortcut Mode")
                )
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(GitHubTheme.textSecondary)
            }
        }
    }

    private var activeColorForEffect: Color {
        switch keyboard.selectedEffect {
        case .staticColor, .breathing, .ripple, .raindrop, .reactive, .sineWave, .laser:
            return keyboard.selectedColor.displayColor
        case .wave, .spectrum, .aurora, .vortex, .snake:
            return Color(hue: Double(ui.previewPhase).truncatingRemainder(dividingBy: 1.0), saturation: 0.95, brightness: 1.0)
        case .userPicture:
            return GitHubTheme.accentPurpleLight
        case .off, .shadows:
            return Color.black.opacity(0.15)
        }
    }
}

// Subview helper for individual simulated keycap
struct KeyCap: View {
    let width: CGFloat?
    let height: CGFloat
    let isRed: Bool
    let isCustom: Bool
    let fallbackColor: Color
    let opacity: Double

    var effectiveColor: Color {
        if isCustom {
            return isRed ? GitHubTheme.dangerRedLight : GitHubTheme.accentPurpleLight
        }
        return fallbackColor
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(effectiveColor.opacity(0.85 * opacity))
                .blur(radius: 1.0)

            RoundedRectangle(cornerRadius: 2)
                .fill(effectiveColor.opacity(opacity))
        }
        .frame(width: width, height: height)
        .frame(maxWidth: width == nil ? .infinity : width)
    }
}

// Function Row: Esc (Red), F1-F12 (Red), Nav
struct FunctionRowView: View {
    let isCustom: Bool
    let fallbackColor: Color
    let opacity: Double

    var body: some View {
        HStack(spacing: 2) {
            // Esc (Red)
            KeyCap(width: 14, height: 8, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // F1-F4 (Red)
            ForEach(0..<4) { _ in
                KeyCap(width: nil, height: 8, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)
            }

            Spacer().frame(width: 4)

            // F5-F8 (Red)
            ForEach(0..<4) { _ in
                KeyCap(width: nil, height: 8, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)
            }

            Spacer().frame(width: 4)

            // F9-F12 (Red)
            ForEach(0..<4) { _ in
                KeyCap(width: nil, height: 8, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)
            }

            // Top-right function keys
            ForEach(0..<2) { _ in
                KeyCap(width: 10, height: 8, isRed: false, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)
            }
        }
        .frame(width: 276)
    }
}

// Number Row: ~, 1-0, -, =, Backspace (Red)
struct NumberRowView: View {
    let isCustom: Bool
    let fallbackColor: Color
    let opacity: Double

    var body: some View {
        HStack(spacing: 2) {
            // `~ (Purple)
            KeyCap(width: nil, height: 10, isRed: false, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // 1-0, -, = (Purple)
            ForEach(0..<12) { _ in
                KeyCap(width: nil, height: 10, isRed: false, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)
            }

            // Backspace (Red)
            KeyCap(width: 26, height: 10, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // Num row end
            KeyCap(width: 10, height: 10, isRed: false, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)
        }
        .frame(width: 276)
    }
}

// QWERTY Row: Tab (Red), Q, W (Red), E, R, T, Y, U, I, O, P, [, ], \
struct QwertyRowView: View {
    let isCustom: Bool
    let fallbackColor: Color
    let opacity: Double

    var body: some View {
        HStack(spacing: 2) {
            // Tab (Red)
            KeyCap(width: 20, height: 10, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // Q (Purple)
            KeyCap(width: nil, height: 10, isRed: false, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // W (Red)
            KeyCap(width: nil, height: 10, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // E-P, [, ], \ (Purple)
            ForEach(0..<10) { _ in
                KeyCap(width: nil, height: 10, isRed: false, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)
            }

            // Numpad key
            KeyCap(width: 10, height: 10, isRed: false, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)
        }
        .frame(width: 276)
    }
}

// Home Row: Caps (Red), A (Red), S (Red), D (Red), F-L, ;, ', Enter (Red)
struct HomeRowView: View {
    let isCustom: Bool
    let fallbackColor: Color
    let opacity: Double

    var body: some View {
        HStack(spacing: 2) {
            // Caps (Red)
            KeyCap(width: 24, height: 10, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // A (Red)
            KeyCap(width: nil, height: 10, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // S (Red)
            KeyCap(width: nil, height: 10, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // D (Red)
            KeyCap(width: nil, height: 10, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // F-L, ;, ' (Purple)
            ForEach(0..<8) { _ in
                KeyCap(width: nil, height: 10, isRed: false, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)
            }

            // Enter (Red)
            KeyCap(width: 28, height: 10, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // Numpad key
            KeyCap(width: 10, height: 10, isRed: false, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)
        }
        .frame(width: 276)
    }
}

// Shift Row: LShift (Red), Z, X, C, V, B, N, M, ,, ., /, RShift (Red), Up (Red)
struct ShiftRowView: View {
    let isCustom: Bool
    let fallbackColor: Color
    let opacity: Double

    var body: some View {
        HStack(spacing: 2) {
            // LShift (Red)
            KeyCap(width: 30, height: 10, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // Z-M, ,, ., / (Purple)
            ForEach(0..<10) { _ in
                KeyCap(width: nil, height: 10, isRed: false, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)
            }

            // RShift (Red)
            KeyCap(width: 26, height: 10, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // Up Arrow (Red)
            KeyCap(width: 12, height: 10, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // Numpad key
            KeyCap(width: 10, height: 10, isRed: false, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)
        }
        .frame(width: 276)
    }
}

// Bottom Row: LCtrl (Red), LWin (Red), LAlt (Red), Space (Purple), RAlt (Red), Fn (Red), RCtrl (Red), Left (Red), Down (Red), Right (Red)
struct BottomRowView: View {
    let isCustom: Bool
    let fallbackColor: Color
    let opacity: Double

    var body: some View {
        HStack(spacing: 2) {
            // LCtrl (Red)
            KeyCap(width: 16, height: 10, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // LWin (Red)
            KeyCap(width: 16, height: 10, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // LAlt (Red)
            KeyCap(width: 16, height: 10, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // Spacebar (Purple)
            KeyCap(width: 82, height: 10, isRed: false, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // RAlt (Red)
            KeyCap(width: 14, height: 10, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // Fn (Red)
            KeyCap(width: 14, height: 10, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // Left (Red)
            KeyCap(width: 12, height: 10, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // Down (Red)
            KeyCap(width: 12, height: 10, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // Right (Red)
            KeyCap(width: 12, height: 10, isRed: true, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)

            // Numpad 0 / Enter
            KeyCap(width: 14, height: 10, isRed: false, isCustom: isCustom, fallbackColor: fallbackColor, opacity: opacity)
        }
        .frame(width: 276)
    }
}
