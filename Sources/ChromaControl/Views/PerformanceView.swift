import SwiftUI

public struct PerformanceView: View {
    @ObservedObject var hardware: RazerHardwareManager

    let dpiStages = [400, 800, 1600, 3200, 6400]
    let pollingRates = [125, 500, 1000]

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // DPI Section
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: "speedometer")
                            .foregroundColor(GitHubTheme.accentGreenLight)
                        Text("DPI SENSITIVITY")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(GitHubTheme.textSecondary)
                        Spacer()
                        Text("\(hardware.currentDpi) DPI")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(GitHubTheme.accentGreenLight)
                    }

                    // Quick Stages
                    HStack(spacing: 8) {
                        ForEach(dpiStages, id: \.self) { stage in
                            Button(action: {
                                hardware.currentDpi = stage
                                hardware.applyCurrentSettings()
                            }) {
                                Text("\(stage)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        hardware.currentDpi == stage ?
                                        GitHubTheme.accentGreen : GitHubTheme.canvasSubtle
                                    )
                                    .foregroundColor(
                                        hardware.currentDpi == stage ?
                                        .white : GitHubTheme.textPrimary
                                    )
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(
                                                hardware.currentDpi == stage ?
                                                GitHubTheme.accentGreen : GitHubTheme.borderDefault,
                                                lineWidth: 1
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Fine slider
                    Slider(value: Binding(
                        get: { Double(hardware.currentDpi) },
                        set: { hardware.currentDpi = Int($0) }
                    ), in: 100...16000, step: 50)
                    .tint(GitHubTheme.accentGreen)

                    Text("Razer Focus+ Optical Sensor supports hardware precision tuning up to 26,000 DPI.")
                        .font(.system(size: 11))
                        .foregroundColor(GitHubTheme.textSecondary)
                }
                .modifier(GitHubCardModifier(padding: 14, cornerRadius: 10))

                // Polling Rate Section
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: "waveform.path.ecg")
                            .foregroundColor(GitHubTheme.accentBlue)
                        Text("POLLING RATE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(GitHubTheme.textSecondary)
                        Spacer()
                        Text("\(hardware.pollingRate) Hz")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(GitHubTheme.accentBlue)
                    }

                    HStack(spacing: 10) {
                        ForEach(pollingRates, id: \.self) { rate in
                            Button(action: {
                                hardware.pollingRate = rate
                                hardware.applyCurrentSettings()
                            }) {
                                VStack(spacing: 4) {
                                    Text("\(rate) Hz")
                                        .font(.system(size: 13, weight: .bold))
                                    Text(rate == 1000 ? "1.0 ms response" : (rate == 500 ? "2.0 ms response" : "8.0 ms response"))
                                        .font(.system(size: 10))
                                        .foregroundColor(
                                            hardware.pollingRate == rate ?
                                            .white.opacity(0.85) : GitHubTheme.textSecondary
                                        )
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    hardware.pollingRate == rate ?
                                    GitHubTheme.accentGreen : GitHubTheme.canvasSubtle
                                )
                                .foregroundColor(
                                    hardware.pollingRate == rate ?
                                    .white : GitHubTheme.textPrimary
                                )
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            hardware.pollingRate == rate ?
                                            GitHubTheme.accentGreen : GitHubTheme.borderDefault,
                                            lineWidth: 1
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Text("Higher polling rates yield the lowest mouse pointer input latency for competitive gaming.")
                        .font(.system(size: 11))
                        .foregroundColor(GitHubTheme.textSecondary)
                }
                .modifier(GitHubCardModifier(padding: 14, cornerRadius: 10))

                // Save button
                HStack {
                    Spacer()
                    Button(action: {
                        hardware.applyCurrentSettings()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Apply Sensitivity & Rate")
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
}
