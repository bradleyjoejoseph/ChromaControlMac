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
        ColorPreset(name: "Razer Green", color: Color(red: 0.0, green: 1.0, blue: 0.2), hex: "#00FF33"),
        ColorPreset(name: "Cyber Yellow", color: Color(red: 1.0, green: 0.85, blue: 0.0), hex: "#FFD700"),
        ColorPreset(name: "Electric Cyan", color: Color(red: 0.0, green: 0.9, blue: 1.0), hex: "#00E5FF"),
        ColorPreset(name: "Deep Blue", color: Color(red: 0.0, green: 0.25, blue: 1.0), hex: "#0040FF"),
        ColorPreset(name: "Ultraviolet", color: Color(red: 0.65, green: 0.0, blue: 1.0), hex: "#A600FF"),
        ColorPreset(name: "Hot Pink", color: Color(red: 1.0, green: 0.0, blue: 0.5), hex: "#FF0080"),
        ColorPreset(name: "Amber Orange", color: Color(red: 1.0, green: 0.45, blue: 0.0), hex: "#FF7300"),
        ColorPreset(name: "Ice White", color: Color(white: 1.0), hex: "#FFFFFF")
    ]

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("QUICK CHROMA PRESETS")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)

            // Preset swatches
            HStack(spacing: 10) {
                ForEach(presets) { preset in
                    Button(action: {
                        selectedColor = preset.color
                        ui.hexInput = preset.hex
                    }) {
                        Circle()
                            .fill(preset.color)
                            .frame(width: 26, height: 26)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: selectedColor == preset.color ? 2.5 : 0)
                            )
                            .shadow(color: preset.color.opacity(0.4), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                    .help(preset.name)
                }
            }

            Divider()
                .padding(.vertical, 4)

            // Custom Color selection & HEX
            HStack(spacing: 16) {
                ColorPicker("Custom Picker", selection: $selectedColor, supportsOpacity: false)
                    .labelsHidden()
                    .frame(width: 32, height: 32)

                HStack {
                    Text("HEX")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)

                    TextField("#FF0000", text: $ui.hexInput)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13, design: .monospaced))
                        .frame(width: 85)
                        .padding(5)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(6)
                        .onSubmit {
                            if !ui.hexInput.isEmpty {
                                selectedColor = Color(hex: ui.hexInput)
                            }
                        }
                }

                // RGB details
                let (r, g, b) = selectedColor.toRGB()
                HStack(spacing: 8) {
                    Text("R: \(r)")
                    Text("G: \(g)")
                    Text("B: \(b)")
                }
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(Color(white: 0.08))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(white: 0.16), lineWidth: 1)
        )
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
