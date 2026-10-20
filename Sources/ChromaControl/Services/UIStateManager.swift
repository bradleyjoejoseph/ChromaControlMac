import SwiftUI

public class UIStateManager: ObservableObject {
    public static let shared = UIStateManager()

    @Published public var selectedTab: MainTab = .lighting
    @Published public var hexInput: String = "#FF0000"
    @Published public var previewPhase: CGFloat = 0.0
    @Published public var breathingOpacity: Double = 1.0

    private var animationTimer: Timer?

    public init() {
        startAnimations()
    }

    deinit {
        animationTimer?.invalidate()
    }

    public func startAnimations() {
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.previewPhase += 0.015
            if self.previewPhase >= 1.0 { self.previewPhase = 0.0 }

            let time = Date().timeIntervalSince1970
            self.breathingOpacity = 0.3 + 0.7 * (sin(time * 2.0) + 1.0) / 2.0
        }
    }
}
