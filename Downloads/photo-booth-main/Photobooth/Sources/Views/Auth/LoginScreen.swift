import SwiftUI

/// Login/Signup screen with multiple auth options
struct LoginScreen: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.theme) var theme
    @State private var isSignUp = false
    @State private var showEmailAuth = false

    var body: some View {
        ZStack {
            // Background
            Color.clear
                .photoboothBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: theme.spacing.xxl) {
                    // Header
                    headerSection

                    // Auth Options
                    VStack(spacing: theme.spacing.lg) {
                        // Note: Apple Sign In requires paid developer account ($99/year)
                        // Uncomment when you have a paid account and add the capability back
                        // AuthButton(
                        //     title: "Continue with Apple",
                        //     icon: "apple.logo",
                        //     style: .primary
                        // ) {
                        //     Task {
                        //         if await authViewModel.signInWithApple(referralCode: appState.pendingReferralCode) {
                        //             appState.isAuthenticated = true
                        //             appState.pendingReferralCode = nil
                        //         }
                        //     }
                        // }

                        // Google Sign In
                        AuthButton(
                            title: "Continue with Google",
                            icon: "g.circle.fill",
                            style: .secondary
                        ) {
                            Task {
                                if await authViewModel.signInWithGoogle(referralCode: appState.pendingReferralCode) {
                                    appState.isAuthenticated = true
                                    appState.pendingReferralCode = nil
                                }
                            }
                        }

                        // Divider
                        HStack {
                            Rectangle()
                                .fill(theme.textSecondary.opacity(0.3))
                                .frame(height: 1)
                            Text("or")
                                .font(Typography.bodySM)
                                .foregroundColor(theme.textSecondary)
                            Rectangle()
                                .fill(theme.textSecondary.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.vertical, theme.spacing.sm)

                        // Email Sign In
                        AuthButton(
                            title: isSignUp ? "Sign up with Email" : "Sign in with Email",
                            icon: "envelope.fill",
                            style: .outline
                        ) {
                            showEmailAuth = true
                        }
                    }
                    .padding(.horizontal)

                    // Toggle Sign Up / Sign In
                    Button {
                        withAnimation {
                            isSignUp.toggle()
                        }
                    } label: {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(Typography.bodySM)
                            .foregroundColor(theme.textSecondary)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 60)
            }
        }
        .sheet(isPresented: $showEmailAuth) {
            EmailAuthSheet(isSignUp: isSignUp)
        }
        .alert("Error", isPresented: $authViewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(authViewModel.errorMessage ?? "An error occurred")
        }
        .overlay {
            if authViewModel.isLoading {
                LoadingOverlay()
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: theme.spacing.lg) {
            // Logo
            ZStack {
                Circle()
                    .fill(theme.cardBackground)
                    .frame(width: 100, height: 100)
                    .shadow(color: theme.text.opacity(0.1), radius: 10)

                Image(systemName: "camera.fill")
                    .font(.system(size: 40))
                    .foregroundColor(theme.text)
            }

            VStack(spacing: theme.spacing.sm) {
                Text("Photobooth")
                    .font(Typography.displayMD)
                    .foregroundColor(theme.text)

                Text("Create stunning AI-styled photo collages")
                    .font(Typography.bodyMD)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Auth Button

struct AuthButton: View {
    @Environment(\.theme) var theme

    let title: String
    let icon: String
    let style: AuthButtonStyle
    let action: () -> Void

    enum AuthButtonStyle {
        case primary, secondary, outline
    }

    @ViewBuilder
    var body: some View {
        let content = Button(action: action) {
            HStack(spacing: theme.spacing.md) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(Typography.bodyLG)
                    .fontWeight(.semibold)
            }
        }

        switch style {
        case .primary:
            content.photoboothPrimaryButton()
        case .secondary, .outline:
            content.photoboothSecondaryButton()
        }
    }
}

// MARK: - Email Auth Sheet

struct EmailAuthSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.theme) var theme
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var authViewModel: AuthViewModel
    let isSignUp: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: theme.spacing.xxl) {
                // Form Fields
                VStack(spacing: theme.spacing.lg) {
                    if isSignUp {
                        TextField("Name", text: $authViewModel.displayName)
                            .textFieldStyle(AuthTextFieldStyle())
                    }

                    TextField("Email", text: $authViewModel.email)
                        .textFieldStyle(AuthTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)

                    SecureField("Password", text: $authViewModel.password)
                        .textFieldStyle(AuthTextFieldStyle())
                        .textContentType(isSignUp ? .newPassword : .password)
                }

                // Submit Button
                Button {
                    Task {
                        let success = isSignUp
                            ? await authViewModel.signUpWithEmail(referralCode: appState.pendingReferralCode)
                            : await authViewModel.signInWithEmail()

                        if success {
                            appState.isAuthenticated = true
                            if isSignUp {
                                appState.pendingReferralCode = nil
                            }
                            dismiss()
                        }
                    }
                } label: {
                    Text(isSignUp ? "Create Account" : "Sign In")
                        .font(Typography.displaySM)
                }
                .photoboothPrimaryButton()

                Spacer()
            }
            .padding(theme.spacing.xl)
            .photoboothBackground()
            .navigationTitle(isSignUp ? "Create Account" : "Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        authViewModel.clearFields()
                        dismiss()
                    }
                    .foregroundColor(theme.text)
                }
            }
        }
    }
}

// MARK: - Text Field Style

struct AuthTextFieldStyle: TextFieldStyle {
    @Environment(\.theme) var theme

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(theme.spacing.lg)
            .background(theme.accent)
            .cornerRadius(theme.corners.medium)
            .font(Typography.bodyLG)
            .foregroundColor(theme.text)
    }
}

// MARK: - Loading Overlay

struct LoadingOverlay: View {
    @Environment(\.theme) var theme

    var body: some View {
        ZStack {
            theme.background.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: theme.spacing.lg) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(theme.text)
                Text("Loading...")
                    .font(Typography.bodyMD)
                    .foregroundColor(theme.textSecondary)
            }
            .photoboothCard()
        }
    }
}

#Preview {
    LoginScreen()
        .environmentObject(AppState())
        .environmentObject(AuthViewModel())
}
