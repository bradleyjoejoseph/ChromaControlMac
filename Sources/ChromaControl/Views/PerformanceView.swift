import SwiftUI

public struct PerformanceView: View {
    @ObservedObject var hardware: RazerHardwareManager

    let dpiStages = [400, 800, 1600, 3200, 6400]
    let pollingRates = [125, 500, 1000]

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // DPI Section
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: "speedometer")
                            .foregroundColor(.green)
                        Text("DPI SENSITIVITY")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(hardware.currentDpi) DPI")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.green)
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
                                    .background(hardware.currentDpi == stage ? Color.green : Color(white: 0.12))
                                    .foregroundColor(hardware.currentDpi == stage ? .black : .white)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Fine slider
                    Slider(value: Binding(
                        get: { Double(hardware.currentDpi) },
                        set: { hardware.currentDpi = Int($0) }
                    ), in: 100...16000, step: 50)
                    .tint(.green)

                    Text("Razer Focus+ Optical Sensor supports up to 26,000 DPI.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color(white: 0.08))
                .cornerRadius(12)

                // Polling Rate
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: "waveform.path.ecg")
                            .foregroundColor(.green)
                        Text("POLLING RATE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(hardware.pollingRate) Hz")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.green)
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
                                        .foregroundColor(hardware.pollingRate == rate ? .black.opacity(0.8) : .secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(hardware.pollingRate == rate ? Color.green : Color(white: 0.12))
                                .foregroundColor(hardware.pollingRate == rate ? .black : .white)
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Text("Higher polling rates provide ultra-low input latency for competitive gaming.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color(white: 0.08))
                .cornerRadius(12)

                // Save button
                HStack {
                    Spacer()
                    Button(action: {
                        hardware.applyCurrentSettings()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Apply Sensitivity & Rate")
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
            }
            .padding(16)
        }
    }
}
