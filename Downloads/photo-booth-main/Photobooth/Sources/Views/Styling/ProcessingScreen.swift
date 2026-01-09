import SwiftUI

/// Loading screen while Gemini processes photos
struct ProcessingScreen: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.theme) var theme
    @StateObject private var styleViewModel = StyleViewModel()

    @State private var isComplete = false
    @State private var showError = false
    @State private var hasStartedProcessing = false

    // Animation states
    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: theme.spacing.xxl) {
            Spacer()

            // Animated Icon
            ZStack {
                // Outer pulse ring
                Circle()
                    .stroke(theme.primary.opacity(0.3), lineWidth: 4)
                    .frame(width: 140, height: 140)
                    .scaleEffect(pulseScale)
                    .opacity(2 - pulseScale)

                // Inner circle
                Circle()
                    .fill(theme.primary)
                    .frame(width: 120, height: 120)
                    .shadow(color: theme.primary.opacity(0.4), radius: 20)

                // Icon
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 44))
                    .foregroundColor(theme.background)
                    .rotationEffect(.degrees(isAnimating ? 10 : -10))
            }

            // Status Text
            VStack(spacing: theme.spacing.sm) {
                Text("Applying \(styleName) Style")
                    .font(Typography.displaySM)
                    .foregroundColor(theme.text)

                Text(statusMessage)
                    .font(Typography.bodyMD)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Progress Indicator
            VStack(spacing: theme.spacing.md) {
                // Photo dots
                HStack(spacing: theme.spacing.md) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(
                                index < styleViewModel.currentPhotoIndex
                                    ? theme.primary
                                    : (index == styleViewModel.currentPhotoIndex && styleViewModel.isProcessing)
                                        ? theme.primary
                                        : theme.textSecondary.opacity(0.3)
                            )
                            .frame(width: 12, height: 12)
                            .scaleEffect(index == styleViewModel.currentPhotoIndex && styleViewModel.isProcessing ? 1.3 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: styleViewModel.currentPhotoIndex)
                    }
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(theme.accent)
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(theme.primary)
                            .frame(width: geometry.size.width * styleViewModel.processingProgress, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: styleViewModel.processingProgress)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 40)

                // Percentage
                Text("\(Int(styleViewModel.processingProgress * 100))%")
                    .font(Typography.bodySM)
                    .foregroundColor(theme.textSecondary)
            }

            Spacer()

            // Tips
            VStack(spacing: theme.spacing.sm) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(theme.text.opacity(0.5))

                Text("Tip: The AI is transforming each photo individually to match the \(styleName) aesthetic.")
                    .font(Typography.bodySM)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.bottom, 40)
        }
        .photoboothBackground()
        .navigationBarHidden(true)
        .onAppear {
            startAnimations()
            startProcessing()
        }
        .onChange(of: isComplete) { _, complete in
            if complete {
                // Store styled photos in app state
                appState.styledPhotos = styleViewModel.styledPhotos
                appState.navigate(to: .customization)
            }
        }
        .alert("Processing Error", isPresented: $showError) {
            Button("Retry") {
                hasStartedProcessing = false
                startProcessing()
            }
            Button("Cancel", role: .cancel) {
                appState.resetSession()
                appState.popToRoot()
            }
        } message: {
            Text(styleViewModel.errorMessage ?? "An error occurred while processing your photos.")
        }
    }

    // MARK: - Computed Properties

    private var styleName: String {
        appState.currentSession?.style?.displayName ?? "JP Kawaii"
    }


    private var statusMessage: String {
        if styleViewModel.isProcessing {
            if styleViewModel.currentPhotoIndex < 4 {
                return "Processing photo \(styleViewModel.currentPhotoIndex + 1) of 4..."
            } else {
                return "Finishing up..."
            }
        } else if styleViewModel.errorMessage != nil {
            return "Processing failed"
        } else {
            return "Starting..."
        }
    }

    // MARK: - Animations

    private func startAnimations() {
        // Pulse animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.3
        }

        // Wobble animation
        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
            isAnimating = true
        }
    }

    // MARK: - Processing

    private func startProcessing() {
        // Prevent duplicate calls from onAppear firing multiple times
        guard !hasStartedProcessing else {
            return
        }
        hasStartedProcessing = true
        
        guard let style = appState.currentSession?.style else {
            styleViewModel.errorMessage = "No style selected"
            showError = true
            return
        }

        guard !appState.capturedPhotos.isEmpty else {
            styleViewModel.errorMessage = "No photos to process"
            showError = true
            return
        }

        Task {
            let success = await styleViewModel.processPhotos(
                appState.capturedPhotos,
                style: style
            )

            if success {
                isComplete = true
            } else {
                showError = true
            }
        }
    }
}

#Preview {
    ProcessingScreen()
        .environmentObject(AppState())
}
