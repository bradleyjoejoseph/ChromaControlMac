import SwiftUI

public enum GitHubTheme {
    // Canvas / Backgrounds
    public static let canvasDefault = Color(red: 13/255, green: 17/255, blue: 23/255)       // #0d1117
    public static let canvasSubtle  = Color(red: 22/255, green: 27/255, blue: 34/255)       // #161b22
    public static let canvasInset   = Color(red: 33/255, green: 38/255, blue: 45/255)       // #21262d
    public static let canvasOverlay = Color(red: 22/255, green: 27/255, blue: 34/255)       // #161b22

    // Borders
    public static let borderDefault = Color(red: 48/255, green: 54/255, blue: 61/255)       // #30363d
    public static let borderMuted   = Color(red: 33/255, green: 38/255, blue: 45/255)       // #21262d

    // Text & Foreground
    public static let textPrimary   = Color(red: 240/255, green: 246/255, blue: 252/255)   // #f0f6fc
    public static let textSecondary = Color(red: 139/255, green: 148/255, blue: 158/255)   // #8b949e
    public static let textTertiary  = Color(red: 110/255, green: 118/255, blue: 129/255)   // #6e7681

    // Accents & Badges
    public static let accentGreen   = Color(red: 35/255, green: 134/255, blue: 54/255)     // #238636 (Primary action)
    public static let accentGreenLight = Color(red: 46/255, green: 160/255, blue: 67/255)  // #2ea043
    public static let accentBlue    = Color(red: 88/255, green: 166/255, blue: 255/255)    // #58a6ff
    public static let accentPurple  = Color(red: 137/255, green: 87/255, blue: 229/255)    // #8957e5
    public static let accentPurpleLight = Color(red: 163/255, green: 113/255, blue: 247/255) // #a371f7
    public static let dangerRed     = Color(red: 218/255, green: 54/255, blue: 51/255)     // #da3633
    public static let dangerRedLight = Color(red: 248/255, green: 81/255, blue: 73/255)    // #f85149
    public static let warningYellow = Color(red: 210/255, green: 153/255, blue: 34/255)    // #d29922
    public static let attentionBg   = Color(red: 187/255, green: 128/255, blue: 9/255).opacity(0.15)
}

public struct GitHubCardModifier: ViewModifier {
    public var padding: CGFloat = 14
    public var cornerRadius: CGFloat = 10

    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(GitHubTheme.canvasInset)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(GitHubTheme.borderDefault, lineWidth: 1)
            )
    }
}

public struct GitHubSubtleCardModifier: ViewModifier {
    public var padding: CGFloat = 12
    public var cornerRadius: CGFloat = 8

    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(GitHubTheme.canvasSubtle)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(GitHubTheme.borderDefault, lineWidth: 1)
            )
    }
}

public extension View {
    func gitHubCard(padding: CGFloat = 14, cornerRadius: CGFloat = 10) -> some View {
        self.modifier(GitHubCardModifier(padding: padding, cornerRadius: cornerRadius))
    }

    func gitHubSubtleCard(padding: CGFloat = 12, cornerRadius: CGFloat = 8) -> some View {
        self.modifier(GitHubSubtleCardModifier(padding: padding, cornerRadius: cornerRadius))
    }
}
