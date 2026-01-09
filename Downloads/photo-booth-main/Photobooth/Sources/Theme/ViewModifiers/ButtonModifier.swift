import SwiftUI

// MARK: - Primary Button Modifier
/// Primary button style with theme colors
/// Usage: .photoboothPrimaryButton()
struct PhotoboothPrimaryButtonModifier: ViewModifier {
    @Environment(\.theme) var theme
    let isDisabled: Bool
    @State private var isPressed = false

    init(isDisabled: Bool = false) {
        self.isDisabled = isDisabled
    }

    func body(content: Content) -> some View {
        content
            .font(Typography.body(16, weight: .bold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, theme.spacing.md)   // 12pt vertical
            .padding(.horizontal, theme.spacing.lg)  // 16pt horizontal
            .background(isDisabled ? theme.secondary.opacity(0.3) : theme.primary)
            .foregroundColor(isDisabled ? theme.textSecondary : theme.background)
            .cornerRadius(theme.corners.medium)
            .shadow(color: isDisabled ? .clear : theme.primary.opacity(0.2), radius: 12, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

// MARK: - Secondary Button Modifier
/// Secondary button style with transparent background
/// Usage: .photoboothSecondaryButton()
struct PhotoboothSecondaryButtonModifier: ViewModifier {
    @Environment(\.theme) var theme
    let isDisabled: Bool
    @State private var isPressed = false

    init(isDisabled: Bool = false) {
        self.isDisabled = isDisabled
    }

    func body(content: Content) -> some View {
        content
            .font(Typography.body(16, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, theme.spacing.md)   // 12pt vertical
            .padding(.horizontal, theme.spacing.lg)  // 16pt horizontal
            .background(isDisabled ? theme.accent.opacity(0.3) : theme.accent)
            .foregroundColor(isDisabled ? theme.textSecondary : theme.text)
            .cornerRadius(theme.corners.medium)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

// MARK: - Tertiary Button Modifier
/// Tertiary button style - text only
/// Usage: .photoboothTertiaryButton()
struct PhotoboothTertiaryButtonModifier: ViewModifier {
    @Environment(\.theme) var theme

    func body(content: Content) -> some View {
        content
            .font(Typography.body(14, weight: .medium))
            .foregroundColor(theme.text)
            .padding(.vertical, theme.spacing.md)
    }
}

// MARK: - Icon Button Modifier
/// Small icon-only button
/// Usage: .photoboothIconButton()
struct PhotoboothIconButtonModifier: ViewModifier {
    @Environment(\.theme) var theme

    func body(content: Content) -> some View {
        content
            .font(.system(size: 20))
            .foregroundColor(theme.text)
            .frame(width: 44, height: 44)
            .background(theme.accent)
            .cornerRadius(theme.corners.medium)
    }
}

// MARK: - View Extensions
extension View {
    /// Apply primary button styling
    func photoboothPrimaryButton(isDisabled: Bool = false) -> some View {
        modifier(PhotoboothPrimaryButtonModifier(isDisabled: isDisabled))
    }

    /// Apply secondary button styling
    func photoboothSecondaryButton(isDisabled: Bool = false) -> some View {
        modifier(PhotoboothSecondaryButtonModifier(isDisabled: isDisabled))
    }

    /// Apply tertiary button styling
    func photoboothTertiaryButton() -> some View {
        modifier(PhotoboothTertiaryButtonModifier())
    }

    /// Apply icon button styling
    func photoboothIconButton() -> some View {
        modifier(PhotoboothIconButtonModifier())
    }

    /// Add press animation (scale effect)
    func pressAnimation() -> some View {
        self.scaleEffect(1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: UUID())
    }
}
