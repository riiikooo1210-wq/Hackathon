import SwiftUI

/// Screen to customize collage layout and colors
struct CustomizationScreen: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.theme) var theme
    @StateObject private var collageViewModel = CollageViewModel()
    @State private var selectedLayout: CollageLayout = .strip
    @State private var selectedColor: Color = .white

    // Preset colors
    private let presetColors: [Color] = [
        .white, .black, .pink, .purple, .blue,
        .mint, .yellow, .orange, .red, .gray
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Preview Area
            collagePreview
                .padding(theme.spacing.xl)

            Divider()
                .background(theme.textSecondary.opacity(0.2))

            // Customization Options
            ScrollView {
                VStack(spacing: theme.spacing.xxl) {
                    // Layout Selection
                    layoutSection

                    // Color Selection
                    colorSection
                }
                .padding(theme.spacing.xl)
            }

            // Continue Button
            Button {
                Task {
                    collageViewModel.selectedLayout = selectedLayout
                    collageViewModel.stripColor = selectedColor
                    if let _ = await collageViewModel.generateCollage(from: appState.styledPhotos) {
                        appState.navigate(to: .preview)
                    }
                }
            } label: {
                HStack {
                    Text("Preview Collage")
                        .font(Typography.displaySM)
                    Image(systemName: "arrow.right")
                }
            }
            .photoboothPrimaryButton()
            .padding(theme.spacing.xl)
        }
        .photoboothBackground()
        .navigationTitle("Customize")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Collage Preview

    private var collagePreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(selectedColor)
                .shadow(color: .black.opacity(0.1), radius: 10)

            // Photo placeholders based on layout
            if selectedLayout == .strip {
                VStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { index in
                        photoPlaceholder(index: index)
                    }
                }
                .padding(12)
            } else {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        photoPlaceholder(index: 0)
                        photoPlaceholder(index: 1)
                    }
                    HStack(spacing: 8) {
                        photoPlaceholder(index: 2)
                        photoPlaceholder(index: 3)
                    }
                }
                .padding(12)
            }
        }
        .aspectRatio(selectedLayout == .strip ? 0.4 : 0.8, contentMode: .fit)
        .frame(maxHeight: 280)
    }

    private func photoPlaceholder(index: Int) -> some View {
        Group {
            if index < appState.styledPhotos.count {
                Image(uiImage: appState.styledPhotos[index].image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
        }
        .cornerRadius(8)
    }

    // MARK: - Layout Section

    private var layoutSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Layout")
                .font(Typography.displaySM)
                .foregroundColor(theme.text)

            HStack(spacing: theme.spacing.lg) {
                ForEach(CollageLayout.allCases, id: \.self) { layout in
                    LayoutOptionButton(
                        layout: layout,
                        isSelected: selectedLayout == layout
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedLayout = layout
                        }
                    }
                }
            }
        }
    }

    // MARK: - Color Section

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Strip Color")
                .font(Typography.displaySM)
                .foregroundColor(theme.text)

            // Preset Colors
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: theme.spacing.md) {
                ForEach(presetColors, id: \.self) { color in
                    ColorButton(
                        color: color,
                        isSelected: selectedColor == color
                    ) {
                        withAnimation(.spring(response: 0.2)) {
                            selectedColor = color
                        }
                    }
                }
            }

            // Color Picker
            HStack {
                Text("Custom Color")
                    .font(Typography.bodyMD)
                    .foregroundColor(theme.textSecondary)

                Spacer()

                ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                    .labelsHidden()
            }
            .padding(.top, theme.spacing.sm)
        }
    }
}

// MARK: - Layout Option Button

struct LayoutOptionButton: View {
    @Environment(\.theme) var theme
    let layout: CollageLayout
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: theme.spacing.sm) {
                // Layout Preview
                ZStack {
                    RoundedRectangle(cornerRadius: theme.corners.small)
                        .fill(theme.accent)
                        .frame(width: 60, height: 80)

                    if layout == .strip {
                        VStack(spacing: 2) {
                            ForEach(0..<4, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(theme.text.opacity(0.5))
                                    .frame(width: 40, height: 14)
                            }
                        }
                    } else {
                        VStack(spacing: 2) {
                            HStack(spacing: 2) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(theme.text.opacity(0.5))
                                    .frame(width: 24, height: 28)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(theme.text.opacity(0.5))
                                    .frame(width: 24, height: 28)
                            }
                            HStack(spacing: 2) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(theme.text.opacity(0.5))
                                    .frame(width: 24, height: 28)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(theme.text.opacity(0.5))
                                    .frame(width: 24, height: 28)
                            }
                        }
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: theme.corners.small)
                        .stroke(isSelected ? theme.primary : Color.clear, lineWidth: 2)
                )

                Text(layout.displayName)
                    .font(Typography.bodySM)
                    .foregroundColor(isSelected ? theme.primary : theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Color Button

struct ColorButton: View {
    @Environment(\.theme) var theme
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Circle()
                .fill(color)
                .frame(width: 44, height: 44)
                .overlay(
                    Circle()
                        .stroke(color == .white ? theme.textSecondary.opacity(0.3) : Color.clear, lineWidth: 1)
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? theme.primary : Color.clear, lineWidth: 3)
                        .padding(2)
                )
                .overlay {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundColor(color == .white || color == .yellow ? .black : .white)
                    }
                }
        }
    }
}

#Preview {
    NavigationStack {
        CustomizationScreen()
            .environmentObject(AppState())
    }
}
