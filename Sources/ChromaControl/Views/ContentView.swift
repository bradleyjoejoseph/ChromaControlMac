import SwiftUI

public enum MainTab: String, CaseIterable, Identifiable {
    case syncAll = "Sync All"
    case mouse = "Mouse"
    case keyboard = "Keyboard"
    case performance = "Performance"
    case about = "About & Help"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .syncAll: return "sparkles.rectangle.stack.fill"
        case .mouse: return "computermouse.fill"
        case .keyboard: return "keyboard.fill"
        case .performance: return "gauge.medium"
        case .about: return "info.circle"
        }
    }
}

public struct ContentView: View {
    @ObservedObject var mouse = RazerHardwareManager.shared
    @ObservedObject var keyboard = AttackSharkManager.shared
    @ObservedObject var ui = UIStateManager.shared

    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack(spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "circle.grid.cross.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.green)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("CHROMA CONTROL")
                            .font(.system(size: 13, weight: .black))
                            .tracking(1.2)
                            .foregroundColor(.white)

                        HStack(spacing: 8) {
                            // Mouse status
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(mouse.isConnected ? Color.green : Color.red)
                                    .frame(width: 6, height: 6)
                                Text("Basilisk V3")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.secondary)
                            }

                            Text("•").foregroundColor(Color(white: 0.3))

                            // Keyboard status
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(keyboard.isConnected ? Color.green : Color.orange)
                                    .frame(width: 6, height: 6)
                                Text("Attack Shark X98")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                Spacer()

                // Tab Switcher
                HStack(spacing: 4) {
                    ForEach(MainTab.allCases) { tab in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                ui.selectedTab = tab
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: tab.icon)
                                Text(tab.rawValue)
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(ui.selectedTab == tab ? Color.white.opacity(0.12) : Color.clear)
                            .foregroundColor(ui.selectedTab == tab ? .green : .white.opacity(0.8))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(4)
                .background(Color(white: 0.08))
                .cornerRadius(10)

                // Refresh Button
                Button(action: {
                    mouse.refreshDevices()
                    keyboard.refreshConnection()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color.white.opacity(0.06))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("Rescan USB peripherals")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(white: 0.05))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(white: 0.12)),
                alignment: .bottom
            )

            // Main Content Area
            HStack(spacing: 0) {
                // Left: Hardware Live Previews
                VStack {
                    Text("LIVE HARDWARE PREVIEW")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.0)
                        .foregroundColor(.secondary)
                        .padding(.top, 14)

                    Spacer()

                    if ui.selectedTab == .syncAll {
                        VStack(spacing: 16) {
                            MousePreviewView(hardware: mouse)
                                .scaleEffect(0.82)
                                .frame(height: 270)
                            KeyboardPreviewView(keyboard: keyboard)
                                .scaleEffect(0.92)
                                .frame(height: 160)
                        }
                    } else if ui.selectedTab == .keyboard {
                        VStack(spacing: 12) {
                            KeyboardPreviewView(keyboard: keyboard)
                            Text("Attack Shark X98 Mechanical Keyboard\nSouth-facing RGB Backlight")
                                .font(.system(size: 11))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        MousePreviewView(hardware: mouse)
                    }

                    Spacer()

                    Text(ui.selectedTab == .keyboard ? "Hardware MCU Table Refresh" : "Click zones to configure independently")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 14)
                }
                .frame(width: 320)
                .background(Color(white: 0.04))
                .overlay(
                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(Color(white: 0.12)),
                    alignment: .trailing
                )

                // Right: Tab Specific Controls
                ZStack {
                    Color(white: 0.06).ignoresSafeArea()

                    switch ui.selectedTab {
                    case .syncAll:
                        EcosystemSyncView(mouse: mouse, keyboard: keyboard)
                    case .mouse:
                        LightingView(hardware: mouse)
                    case .keyboard:
                        KeyboardLightingView(keyboard: keyboard)
                    case .performance:
                        PerformanceView(hardware: mouse)
                    case .about:
                        AboutView()
                    }
                }
            }

            // Footer Status Bar
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "memorychip")
                        .foregroundColor(.green)
                    Text(mouse.lastStatusMessage)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text("•").foregroundColor(Color(white: 0.3))
                    Text(keyboard.lastStatusMessage)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("macOS • Razer Basilisk V3 + Attack Shark X98")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(white: 0.03))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(white: 0.1)),
                alignment: .top
            )
        }
        .frame(minWidth: 920, minHeight: 720)
        .background(Color(white: 0.04))
        .preferredColorScheme(.dark)
    }
}

public struct AboutView: View {
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 16) {
                    Image(systemName: "circle.grid.cross.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.green)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Chroma Control for macOS")
                            .font(.system(size: 18, weight: .bold))
                        Text("Version 1.1.0 • Unified Mouse & Keyboard Ecosystem")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }

                Text("Unified macOS lighting and performance hub for your desk setup. Communicates directly with both your Razer mouse and Attack Shark mechanical keyboard via Apple IOKit USB HID without telemetry or browser barriers.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)

                // Hardware capabilities & differences
                VStack(alignment: .leading, spacing: 14) {
                    Text("DEVICE ARCHITECTURE & LIMITATIONS GUIDE")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.green)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("1. Razer Basilisk V3 (Wired)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                        Text("• Fully programmable per-zone addressable RGB (Logo, Scroll Wheel, and 11 individual underglow LEDs).\n• Supports full hardware effects (Static, Breathing, Wave, Spectrum, Reactive).\n• Hardware flash persistence: commands write to VARSTORE onboard memory and persist indefinitely across machines.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)

                        Divider()

                        Text("2. Attack Shark X98 (Mechanical Keyboard)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                        Text("• The X98 uses an integrated Shinetek MCU (0x1A2C:0xA034) with 21 pre-programmed lighting algorithms and 7 hardware colors.\n• Why web drivers fail on Mac: The online qmk.top tool uses WebHID, which macOS browser sandboxes block from accessing keyboard interfaces. ChromaControl bypasses this by talking directly to the 0xFF02 vendor pipe.\n• Limitation: The MCU runs built-in effect tables rather than streaming raw per-key dynamic frames. This ensures 1000Hz gaming polling rate with 0% CPU overhead.\n• Onboard manual overrides: If running on battery or Bluetooth, you can always use the hardware shortcuts: Fn + \\ (Cycle 21 Effects), Fn + Enter (Cycle 7 Colors), Fn + ↑/↓ (Brightness), Fn + ←/→ (Speed).")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(14)
                    .background(Color(white: 0.08))
                    .cornerRadius(10)
                }
            }
            .padding(24)
        }
    }
}
