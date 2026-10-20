import SwiftUI

public struct MousePreviewView: View {
    @ObservedObject var hardware: RazerHardwareManager
    @ObservedObject var ui = UIStateManager.shared

    private func colorFor(zone: LightingZone) -> Color {
        let state = hardware.syncAllZones ? (hardware.zoneStates[.all] ?? ZoneLightingState()) : (hardware.zoneStates[zone] ?? ZoneLightingState())
        switch state.effect {
        case .staticColor, .reactive, .breathing:
            return state.primaryColor
        case .spectrum, .wave:
            return Color(hue: Double(ui.previewPhase).truncatingRemainder(dividingBy: 1.0), saturation: 1.0, brightness: 1.0)
        case .off:
            return Color.black.opacity(0.1)
        }
    }

    public var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Background ambient glow from mouse
                RoundedRectangle(cornerRadius: 32)
                    .fill(
                        RadialGradient(
                            colors: [
                                colorFor(zone: .underglow).opacity(0.25 * (hardware.globalBrightness / 100.0)),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 180
                        )
                    )
                    .frame(width: 320, height: 420)

                // Mouse Body Silhouette
                ZStack {
                    // Outer Underglow Rim Glow
                    MouseBodyShape()
                        .stroke(
                            colorFor(zone: .underglow)
                                .opacity(0.8 * (hardware.globalBrightness / 100.0) * ui.breathingOpacity),
                            lineWidth: 5
                        )
                        .blur(radius: 6)
                        .frame(width: 190, height: 320)

                    // Mouse Base
                    MouseBodyShape()
                        .fill(
                            LinearGradient(
                                colors: [Color(white: 0.14), Color(white: 0.08), Color(white: 0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            MouseBodyShape()
                                .stroke(Color(white: 0.22), lineWidth: 1.5)
                        )
                        .shadow(color: .black.opacity(0.8), radius: 15, x: 0, y: 10)
                        .frame(width: 190, height: 320)

                    // Thumb rest contour (Basilisk style)
                    Path { path in
                        path.move(to: CGPoint(x: 20, y: 170))
                        path.addQuadCurve(to: CGPoint(x: 5, y: 220), control: CGPoint(x: 8, y: 190))
                        path.addQuadCurve(to: CGPoint(x: 25, y: 270), control: CGPoint(x: 10, y: 250))
                    }
                    .stroke(Color(white: 0.2), lineWidth: 2)

                    // Main Left/Right button separation lines
                    Path { path in
                        path.move(to: CGPoint(x: 95, y: 25))
                        path.addLine(to: CGPoint(x: 95, y: 110))
                    }
                    .stroke(Color(white: 0.2), lineWidth: 1.5)

                    // 1. SCROLL WHEEL ZONE
                    ZStack {
                        Capsule()
                            .fill(Color(white: 0.05))
                            .frame(width: 24, height: 50)
                            .overlay(
                                Capsule().stroke(Color(white: 0.25), lineWidth: 1)
                            )

                        Capsule()
                            .fill(
                                colorFor(zone: .scrollWheel)
                                    .opacity(0.9 * (hardware.globalBrightness / 100.0) * ui.breathingOpacity)
                            )
                            .frame(width: 16, height: 40)
                            .blur(radius: 3)

                        Capsule()
                            .fill(
                                colorFor(zone: .scrollWheel)
                                    .opacity(hardware.globalBrightness / 100.0 * ui.breathingOpacity)
                            )
                            .frame(width: 12, height: 34)

                        // Scroll ridges
                        VStack(spacing: 5) {
                            ForEach(0..<4) { _ in
                                Rectangle()
                                    .fill(Color.black.opacity(0.5))
                                    .frame(width: 14, height: 2)
                            }
                        }
                    }
                    .position(x: 95, y: 75)
                    .onTapGesture {
                        withAnimation { hardware.selectedZone = .scrollWheel }
                    }

                    // DPI Switch Buttons behind scroll wheel
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(white: 0.2))
                            .frame(width: 10, height: 12)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(white: 0.2))
                            .frame(width: 10, height: 12)
                    }
                    .position(x: 95, y: 130)

                    // 2. LOGO ZONE (Palm Rest)
                    ZStack {
                        Image(systemName: "shield.checkered")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 38, height: 38)
                            .foregroundColor(
                                colorFor(zone: .logo)
                                    .opacity(0.85 * (hardware.globalBrightness / 100.0) * ui.breathingOpacity)
                            )
                            .blur(radius: 4)

                        Image(systemName: "shield.checkered")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 34, height: 34)
                            .foregroundColor(
                                colorFor(zone: .logo)
                                    .opacity(hardware.globalBrightness / 100.0 * ui.breathingOpacity)
                            )
                    }
                    .position(x: 95, y: 235)
                    .onTapGesture {
                        withAnimation { hardware.selectedZone = .logo }
                    }

                    // 3. UNDERGLOW LEDS (Basilisk V3 11-LED rim indicator)
                    UnderglowRimView(color: colorFor(zone: .underglow), brightness: hardware.globalBrightness / 100.0 * ui.breathingOpacity)
                        .onTapGesture {
                            withAnimation { hardware.selectedZone = .underglow }
                        }
                }
                .frame(width: 190, height: 320)
            }
            .frame(height: 340)

            // Zone quick selection tags
            HStack(spacing: 8) {
                ForEach(LightingZone.allCases) { zone in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            hardware.selectedZone = zone
                        }
                    }) {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(colorFor(zone: zone))
                                .frame(width: 8, height: 8)
                            Text(zone.rawValue)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            hardware.selectedZone == zone ?
                            Color.green.opacity(0.2) : Color.white.opacity(0.06)
                        )
                        .foregroundColor(hardware.selectedZone == zone ? .green : .white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(hardware.selectedZone == zone ? Color.green : Color.clear, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// Mouse shape contoured for Basilisk V3 ergonomic profile
struct MouseBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: w * 0.35, y: 0))
        path.addLine(to: CGPoint(x: w * 0.15, y: h * 0.08))
        path.addQuadCurve(to: CGPoint(x: 0, y: h * 0.65), control: CGPoint(x: w * 0.05, y: h * 0.35))
        path.addQuadCurve(to: CGPoint(x: w * 0.15, y: h * 0.90), control: CGPoint(x: 0, y: h * 0.82))
        path.addQuadCurve(to: CGPoint(x: w * 0.85, y: h * 0.90), control: CGPoint(x: w * 0.5, y: h * 1.0))
        path.addQuadCurve(to: CGPoint(x: w * 0.90, y: h * 0.45), control: CGPoint(x: w * 0.98, y: h * 0.75))
        path.addQuadCurve(to: CGPoint(x: w * 0.70, y: 0), control: CGPoint(x: w * 0.85, y: h * 0.12))
        path.closeSubpath()

        return path
    }
}

struct UnderglowRimView: View {
    let color: Color
    let brightness: Double

    var body: some View {
        ZStack {
            ForEach(0..<11) { i in
                let angle = Double(i) * 16.0 + 100.0
                let rad = angle * .pi / 180.0
                let x = 95.0 + cos(rad) * 80.0
                let y = 260.0 + sin(rad) * 45.0

                Circle()
                    .fill(color.opacity(brightness))
                    .frame(width: 6, height: 6)
                    .blur(radius: 1)
                    .position(x: x, y: y)
            }
        }
    }
}
