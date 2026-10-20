import SwiftUI

public enum MainTab: String, CaseIterable, Identifiable {
    case lighting = "Lighting"
    case performance = "Performance"
    case profiles = "Profiles"
    case about = "About"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .lighting: return "sparkles"
        case .performance: return "gauge.medium"
        case .profiles: return "folder.fill"
        case .about: return "info.circle"
        }
    }
}

public struct ContentView: View {
    @ObservedObject var hardware = RazerHardwareManager.shared
    @ObservedObject var ui = UIStateManager.shared

    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack(spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "computermouse.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.green)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("CHROMA CONTROL")
                            .font(.system(size: 13, weight: .black))
                            .tracking(1.2)
                            .foregroundColor(.white)
                        HStack(spacing: 6) {
                            Circle()
                                .fill(hardware.isConnected ? Color.green : Color.red)
                                .frame(width: 7, height: 7)
                            Text(hardware.deviceName)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
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
                            .padding(.horizontal, 12)
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
                    hardware.refreshDevices()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color.white.opacity(0.06))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("Scan for Razer peripherals")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color(white: 0.05))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(white: 0.12)),
                alignment: .bottom
            )

            // Main Content Area
            HStack(spacing: 0) {
                // Left: Interactive Mouse Silhouette with Live Lighting
                VStack {
                    Text("LIVE HARDWARE PREVIEW")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.0)
                        .foregroundColor(.secondary)
                        .padding(.top, 16)

                    Spacer()

                    MousePreviewView(hardware: hardware)

                    Spacer()

                    Text("Click on zones to configure independently")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 16)
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
                    case .lighting:
                        LightingView(hardware: hardware)
                    case .performance:
                        PerformanceView(hardware: hardware)
                    case .profiles:
                        ProfilesView(hardware: hardware)
                    case .about:
                        AboutView()
                    }
                }
            }

            // Footer Status Bar
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "memorychip")
                        .foregroundColor(.green)
                    Text(hardware.lastStatusMessage)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("macOS Native • Basilisk V3 (0x0099)")
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
        .frame(minWidth: 880, minHeight: 680)
        .background(Color(white: 0.04))
        .preferredColorScheme(.dark)
    }
}

public struct AboutView: View {
    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "computermouse.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.green)

            VStack(spacing: 6) {
                Text("Chroma Control for macOS")
                    .font(.system(size: 20, weight: .bold))
                Text("Version 1.0.0")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            Text("Full native macOS alternative to Razer Synapse for RGB Chroma lighting, DPI stages, and polling rate management. Directly interfaces with Razer hardware via IOKit USB HID without telemetry or account requirements.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 480)

            VStack(alignment: .leading, spacing: 8) {
                Label("Clean-room IOKit USB HID direct communication", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Label("All 11 underglow, logo, and scroll wheel zones", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Label("Hardware onboard memory storage (VARSTORE)", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Label("Lightweight, instantaneous, 100% native Swift & C", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            .font(.system(size: 12))
            .padding()
            .background(Color(white: 0.09))
            .cornerRadius(12)
        }
        .padding(30)
    }
}
