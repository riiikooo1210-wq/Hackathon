import SwiftUI

// MARK: - Typography System
struct Typography {
    // MARK: - Display Font (Be Vietnam Pro)
    /// Use for headings, titles, and emphasis text
    /// Falls back to system font if Be Vietnam Pro is not available
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        // Try custom font first
        if let _ = UIFont(name: "BeVietnamPro-Bold", size: size) {
            return Font.custom(fontName(for: weight), size: size)
        }
        // Fallback to system font
        return Font.system(size: size, weight: weight, design: .default)
    }

    // MARK: - Body Font (System SF Pro)
    /// Use for body text, descriptions, and UI labels
    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .default)
    }

    // MARK: - Size Presets (matching web app design)

    // Display sizes
    static let displayXL = display(120, weight: .black)      // Hero countdown
    static let displayLG = display(64, weight: .black)       // Main headings
    static let displayMD = display(32, weight: .bold)        // Section titles
    static let displaySM = display(24, weight: .bold)        // Card titles

    // Body sizes
    static let bodyLG = body(16, weight: .regular)           // Standard text
    static let bodyMD = body(14, weight: .regular)           // Secondary text
    static let bodySM = body(12, weight: .semibold)          // Captions
    static let bodyXS = body(11, weight: .semibold)          // Small labels

    // MARK: - Private Helper
    private static func fontName(for weight: Font.Weight) -> String {
        switch weight {
        case .black:
            return "BeVietnamPro-Black"
        case .bold, .heavy:
            return "BeVietnamPro-Bold"
        case .semibold, .medium:
            return "BeVietnamPro-Medium"
        default:
            return "BeVietnamPro-Regular"
        }
    }
}

// MARK: - Text Extension for Tracking (Letter Spacing)
extension View {
    /// Apply letter-spacing similar to Tailwind's tracking-tight
    func trackingTight() -> some View {
        self.tracking(-0.5)
    }

    /// Apply letter-spacing similar to Tailwind's tracking-wide
    func trackingWide() -> some View {
        self.tracking(1.0)
    }

    /// Apply letter-spacing similar to Tailwind's tracking-wider
    func trackingWider() -> some View {
        self.tracking(1.5)
    }
}
