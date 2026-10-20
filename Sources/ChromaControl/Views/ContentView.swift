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
            // MARK: - Header Bar (GitHub Canvas Subtle)
            HStack(spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "circle.grid.cross.fill")
                        .font(.system(size: 20))
                        .foregroundColor(GitHubTheme.accentGreenLight)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("CHROMA CONTROL")
                            .font(.system(size: 13, weight: .black))
                            .tracking(1.2)
                            .foregroundColor(GitHubTheme.textPrimary)

                        HStack(spacing: 8) {
                            // Mouse status
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(mouse.isConnected ? GitHubTheme.accentGreenLight : GitHubTheme.dangerRedLight)
                                    .frame(width: 6, height: 6)
                                Text("Basilisk V3")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(GitHubTheme.textSecondary)
                            }

                            Text("•").foregroundColor(GitHubTheme.borderDefault)

                            // Keyboard status
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(keyboard.isConnected ? GitHubTheme.accentGreenLight : GitHubTheme.warningYellow)
                                    .frame(width: 6, height: 6)
                                Text("Attack Shark X98")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(GitHubTheme.textSecondary)
                            }
                        }
                    }
                }

                Spacer()

                // Tab Switcher (Apple HIG Native Segmented Feel with GitHub Palette)
                HStack(spacing: 4) {
                    ForEach(MainTab.allCases) { tab in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                ui.selectedTab = tab
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 11))
                                Text(tab.rawValue)
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                ui.selectedTab == tab ?
                                GitHubTheme.canvasInset : Color.clear
                            )
                            .foregroundColor(
                                ui.selectedTab == tab ?
                                GitHubTheme.textPrimary : GitHubTheme.textSecondary
                            )
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(
                                        ui.selectedTab == tab ?
                                        GitHubTheme.borderDefault : Color.clear,
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(3)
                .background(GitHubTheme.canvasDefault)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(GitHubTheme.borderDefault, lineWidth: 1)
                )

                // USB Rescan Button
                Button(action: {
                    mouse.refreshDevices()
                    keyboard.refreshConnection()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                        .foregroundColor(GitHubTheme.textSecondary)
                        .padding(7)
                        .background(GitHubTheme.canvasInset)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(GitHubTheme.borderDefault, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .help("Rescan USB peripherals via Apple IOKit")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(GitHubTheme.canvasSubtle)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(GitHubTheme.borderDefault),
                alignment: .bottom
            )

            // MARK: - Main Content Area
            HStack(spacing: 0) {
                // Left: Hardware Live Previews Pane
                VStack {
                    Text("LIVE HARDWARE PREVIEW")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.0)
                        .foregroundColor(GitHubTheme.textTertiary)
                        .padding(.top, 14)

                    Spacer()

                    if ui.selectedTab == .syncAll {
                        VStack(spacing: 16) {
                            MousePreviewView(hardware: mouse)
                                .scaleEffect(0.80)
                                .frame(height: 250)
                            KeyboardPreviewView(keyboard: keyboard)
                                .scaleEffect(0.90)
                                .frame(height: 160)
                        }
                    } else if ui.selectedTab == .keyboard {
                        VStack(spacing: 12) {
                            KeyboardPreviewView(keyboard: keyboard)
                            Text("Attack Shark X98 Mechanical Keyboard\nSouth-facing RGB Backlight")
                                .font(.system(size: 11))
                                .multilineTextAlignment(.center)
                                .foregroundColor(GitHubTheme.textSecondary)
                        }
                    } else {
                        MousePreviewView(hardware: mouse)
                    }

                    Spacer()

                    Text(ui.selectedTab == .keyboard ? "Live South-Facing LED Simulation" : "Click zones to configure independently")
                        .font(.system(size: 10))
                        .foregroundColor(GitHubTheme.textTertiary)
                        .padding(.bottom, 14)
                }
                .frame(width: 320)
                .background(GitHubTheme.canvasSubtle)
                .overlay(
                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(GitHubTheme.borderDefault),
                    alignment: .trailing
                )

                // Right: Tab Specific Controls
                ZStack {
                    GitHubTheme.canvasDefault.ignoresSafeArea()

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

            // MARK: - Footer Status Bar
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "memorychip")
                        .font(.system(size: 11))
                        .foregroundColor(GitHubTheme.accentGreenLight)
                    Text(mouse.lastStatusMessage)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(GitHubTheme.textSecondary)
                    Text("•").foregroundColor(GitHubTheme.borderDefault)
                    Text(keyboard.lastStatusMessage)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(GitHubTheme.textSecondary)
                }

                Spacer()

                Text("macOS • Razer Basilisk V3 + Attack Shark X98")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(GitHubTheme.textTertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 7)
            .background(GitHubTheme.canvasSubtle)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(GitHubTheme.borderDefault),
                alignment: .top
            )
        }
        .frame(minWidth: 940, minHeight: 720)
        .background(GitHubTheme.canvasDefault)
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
                        .frame(width: 48, height: 48)
                        .foregroundColor(GitHubTheme.accentGreenLight)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Chroma Control for macOS")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(GitHubTheme.textPrimary)
                        Text("Version 1.2.0 • Unified Razer & Attack Shark Ecosystem")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(GitHubTheme.textSecondary)
                    }
                }

                Text("Unified native macOS lighting and performance control hub for your desk setup. Communicates directly with both your Razer Basilisk V3 mouse and Attack Shark X98 mechanical keyboard via Apple IOKit USB HID without telemetry or browser barriers.")
                    .font(.system(size: 13))
                    .foregroundColor(GitHubTheme.textSecondary)

                VStack(alignment: .leading, spacing: 14) {
                    Text("DEVICE ARCHITECTURE & CAPABILITIES GUIDE")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(GitHubTheme.accentGreenLight)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("1. Razer Basilisk V3 (Wired)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(GitHubTheme.textPrimary)
                        Text("• Fully programmable per-zone addressable RGB (Logo, Scroll Wheel, and 11 individual underglow LEDs).\n• Supports full hardware effects (Static, Breathing, Wave, Spectrum, Reactive).\n• Hardware flash persistence: commands write directly to VARSTORE onboard memory and persist indefinitely across reboots and different machines.")
                            .font(.system(size: 12))
                            .foregroundColor(GitHubTheme.textSecondary)

                        Divider().background(GitHubTheme.borderDefault)

                        Text("2. Attack Shark X98 (Mechanical Keyboard)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(GitHubTheme.textPrimary)
                        Text("• The X98 uses a Shinetek MCU (0x1A2C:0xA034) with 21 hardware effects and custom per-key lighting tables.\n• Per-Key Matrix: ChromaControl sends 7 sequential 64-byte chunks of Command 0x0C (FEA_CMD_SET_USERPIC) with bit-7 checksums to paint custom RGB colors across all keys, followed by Command 0x07 (LightUserPicture) to render it immediately.\n• Why web drivers fail on Mac: The online qmk.top tool relies on WebHID, which macOS browser sandboxes restrict. ChromaControl communicates directly with the 0xFF02 vendor pipe via native IOKit.\n• Hardware shortcuts: Fn + \\ (Cycle 21 Effects) • Fn + Enter (Cycle 7 Colors) • Fn + ↑/↓ (Brightness) • Fn + ←/→ (Speed).")
                            .font(.system(size: 12))
                            .foregroundColor(GitHubTheme.textSecondary)
                    }
                    .modifier(GitHubCardModifier(padding: 14, cornerRadius: 10))
                }
            }
            .padding(24)
        }
        .background(GitHubTheme.canvasDefault)
    }
}
