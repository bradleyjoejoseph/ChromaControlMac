import SwiftUI

public struct ColorPreset: Identifiable {
    public var id: String { name }
    public let name: String
    public let color: Color
    public let hex: String
}

public struct ColorPickerView: View {
    @Binding var selectedColor: Color
    @ObservedObject var ui = UIStateManager.shared

    public let presets: [ColorPreset] = [
        ColorPreset(name: "Crimson Red", color: Color(red: 1.0, green: 0.0, blue: 0.0), hex: "#FF0000"),
        ColorPreset(name: "Violet Purple", color: Color(red: 0.65, green: 0.0, blue: 1.0), hex: "#A600FF"),
        ColorPreset(name: "Razer Green", color: Color(red: 0.14, green: 0.75, blue: 0.28), hex: "#23C047"),
        ColorPreset(name: "Cyber Yellow", color: Color(red: 1.0, green: 0.85, blue: 0.0), hex: "#FFD700"),
        ColorPreset(name: "Electric Cyan", color: Color(red: 0.0, green: 0.9, blue: 1.0), hex: "#00E5FF"),
        ColorPreset(name: "Deep Blue", color: Color(red: 0.0, green: 0.35, blue: 1.0), hex: "#0059FF"),
        ColorPreset(name: "Pure White", color: Color(white: 1.0), hex: "#FFFFFF")
    ]

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("QUICK CHROMA PRESETS")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(GitHubTheme.textSecondary)

            // Preset Swatches
            HStack(spacing: 8) {
                ForEach(presets) { preset in
                    Button(action: {
                        selectedColor = preset.color
                        ui.hexInput = preset.hex
                    }) {
                        Circle()
                            .fill(preset.color)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: selectedColor == preset.color ? 2 : 0)
                            )
                            .shadow(color: preset.color.opacity(0.3), radius: 3, x: 0, y: 1)
                    }
                    .buttonStyle(.plain)
                    .help(preset.name)
                }
            }

            Divider()
                .background(GitHubTheme.borderDefault)
                .padding(.vertical, 2)

            // Custom Color selection & HEX
            HStack(spacing: 14) {
                ColorPicker("Custom Picker", selection: $selectedColor, supportsOpacity: false)
                    .labelsHidden()
                    .frame(width: 28, height: 28)

                HStack(spacing: 6) {
                    Text("HEX")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(GitHubTheme.textSecondary)

                    TextField("#FF0000", text: $ui.hexInput)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(GitHubTheme.textPrimary)
                        .frame(width: 80)
                        .padding(5)
                        .background(GitHubTheme.canvasSubtle)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(GitHubTheme.borderDefault, lineWidth: 1)
                        )
                        .onSubmit {
                            if !ui.hexInput.isEmpty {
                                selectedColor = Color(hex: ui.hexInput)
                            }
                        }
                }

                // RGB details
                let (r, g, b) = selectedColor.toRGB()
                HStack(spacing: 6) {
                    Text("R: \(r)")
                    Text("G: \(g)")
                    Text("B: \(b)")
                }
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(GitHubTheme.textSecondary)
            }
        }
        .modifier(GitHubSubtleCardModifier(padding: 12, cornerRadius: 8))
        .onAppear {
            let (r, g, b) = selectedColor.toRGB()
            ui.hexInput = String(format: "#%02X%02X%02X", r, g, b)
        }
        .onChange(of: selectedColor) { newColor in
            let (r, g, b) = newColor.toRGB()
            ui.hexInput = String(format: "#%02X%02X%02X", r, g, b)
        }
    }
}
