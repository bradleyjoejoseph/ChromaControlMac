import SwiftUI

public enum MainTab: String, CaseIterable, Identifiable {
    case lighting = "Lighting"
    case performance = "Performance"
    case profiles = "Profiles"
    case about = "About & Help"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .lighting: return "sun.max.fill"
        case .performance: return "gauge.medium"
        case .profiles: return "sparkles.rectangle.stack.fill"
        case .about: return "info.circle"
        }
    }
}

public struct ContentView: View {
    @ObservedObject var mouse = RazerHardwareManager.shared
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

                        HStack(spacing: 6) {
                            Circle()
                                .fill(mouse.isConnected ? GitHubTheme.accentGreenLight : GitHubTheme.dangerRedLight)
                                .frame(width: 6, height: 6)
                            Text(mouse.deviceName)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(GitHubTheme.textSecondary)
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
                            .padding(.horizontal, 12)
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
                // Left: Hardware Live Preview
                VStack {
                    Text("LIVE HARDWARE PREVIEW")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.0)
                        .foregroundColor(GitHubTheme.textTertiary)
                        .padding(.top, 14)

                    Spacer()

                    MousePreviewView(hardware: mouse)

                    Spacer()

                    Text("Click zones to configure independently")
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
                    case .lighting:
                        LightingView(hardware: mouse)
                    case .performance:
                        PerformanceView(hardware: mouse)
                    case .profiles:
                        ProfilesView(hardware: mouse)
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
                }

                Spacer()

                Text("macOS • Razer Basilisk V3 (0x1532:0x0099)")
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
        .frame(minWidth: 920, minHeight: 680)
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
                        Text("Version 1.3.0 • Native Razer Chroma Controller")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(GitHubTheme.textSecondary)
                    }
                }

                Text("Lightweight native macOS lighting and performance control hub for your Razer mouse. Communicates directly with your hardware via Apple IOKit USB HID without telemetry, Synapse bloat, or background memory leaks.")
                    .font(.system(size: 13))
                    .foregroundColor(GitHubTheme.textSecondary)

                VStack(alignment: .leading, spacing: 14) {
                    Text("FEATURES & CAPABILITIES")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(GitHubTheme.accentGreenLight)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Razer Basilisk V3")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(GitHubTheme.textPrimary)
                        Text("• Fully programmable per-zone addressable RGB (Logo, Scroll Wheel, and 11 individual underglow LEDs).\n• Supports full hardware effects (Static Solid, Breathing, Spectrum Cycling, Wave, Reactive, Off).\n• Sensor DPI adjustment up to 26,000 DPI with quick tournament stages (400, 800, 1600, 3200, 6400).\n• Hardware polling rate switching (125Hz, 500Hz, 1000Hz).\n• Onboard flash persistence: commands write directly to VARSTORE non-volatile memory so your settings persist across reboots without software running.")
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
