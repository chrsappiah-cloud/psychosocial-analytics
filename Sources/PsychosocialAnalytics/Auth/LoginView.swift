import SwiftUI

public enum LoginTab: String, CaseIterable {
    case `public`
    case administrator

    public var title: String {
        switch self {
        case .public: return "Public Access"
        case .administrator: return "Administrator"
        }
    }

    public var icon: String {
        switch self {
        case .public: return "person.fill"
        case .administrator: return "lock.shield.fill"
        }
    }
}

public struct LoginView: View {
    @StateObject private var access = AccessControlService.shared
    @StateObject private var payments = StoreKitPaymentService.shared
    @State private var selectedTab: LoginTab = .public

    @State private var email: String = ""
    @State private var displayName: String = ""
    @State private var password: String = ""
    @State private var selectedRole: AppRole = .user
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    public let onAuthenticated: () -> Void

    public init(onAuthenticated: @escaping () -> Void) {
        self.onAuthenticated = onAuthenticated
    }

    public var body: some View {
        ZStack {
            AmbientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer().frame(height: 40)

                    BrandMark(size: 72)

                    VStack(spacing: 4) {
                        Text(AppBrand.nameLine1)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(PremiumTheme.textPrimary)
                        Text(AppBrand.nameLine2)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(AppBrand.nameGradient)
                    }

                    Text(AppBrand.tagline)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(PremiumTheme.textSecondary)
                        .multilineTextAlignment(.center)

                    loginTabSelector

                    PremiumTheme.cardStyle {
                        loginForm
                    }
                    .padding(.horizontal, 24)

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(PremiumTheme.danger)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    Spacer().frame(height: 40)
                }
                .frame(maxWidth: 420)
                .frame(maxWidth: .infinity)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var loginTabSelector: some View {
        HStack(spacing: 0) {
            ForEach(LoginTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                        errorMessage = nil
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.title3)
                        Text(tab.title)
                            .font(.caption.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedTab == tab
                            ? PremiumTheme.emerald.opacity(0.15)
                            : Color.clear,
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
                    .foregroundStyle(
                        selectedTab == tab
                            ? PremiumTheme.emeraldLight
                            : PremiumTheme.textSecondary
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(PremiumTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(PremiumTheme.border, lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private var loginForm: some View {
        switch selectedTab {
        case .public:
            publicLoginFields
        case .administrator:
            adminLoginFields
        }
    }

    private var publicLoginFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            BrandedSectionTitle("Sign In", subtitle: "Enter your credentials to continue")

            VStack(alignment: .leading, spacing: 6) {
                Text("Email").font(.caption.weight(.medium)).foregroundStyle(PremiumTheme.textSecondary)
                TextField("you@example.com", text: $email)
                    .textFieldStyle()
                    #if os(iOS)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    #endif
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Display Name").font(.caption.weight(.medium)).foregroundStyle(PremiumTheme.textSecondary)
                TextField("Dr. Jane Smith", text: $displayName)
                    .textFieldStyle()
                    #if os(iOS)
                    .textContentType(.name)
                    #endif
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Role").font(.caption.weight(.medium)).foregroundStyle(PremiumTheme.textSecondary)
                Picker("Role", selection: $selectedRole) {
                    ForEach(AppRole.allCases, id: \.self) { role in
                        Text(role.displayName).tag(role)
                    }
                }
                .pickerStyle(.segmented)
            }

            Button {
                submitPublicLogin()
            } label: {
                HStack {
                    if isSubmitting {
                        ProgressView().tint(PremiumTheme.background)
                    }
                    Text("Sign In")
                        .font(.body.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
            }
            .psychosocialPrimaryButton()
            .disabled(isSubmitting || email.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(isSubmitting || email.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1)
        }
    }

    private var adminLoginFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            BrandedSectionTitle("Administrator Access", subtitle: "Restricted to authorized personnel")

            VStack(alignment: .leading, spacing: 6) {
                Text("Email").font(.caption.weight(.medium)).foregroundStyle(PremiumTheme.textSecondary)
                TextField("admin@psychosocialanalytics.com", text: $email)
                    .textFieldStyle()
                    #if os(iOS)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    #endif
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Password").font(.caption.weight(.medium)).foregroundStyle(PremiumTheme.textSecondary)
                SecureField("Enter administrator password", text: $password)
                    .textFieldStyle()
                    #if os(iOS)
                    .textContentType(.password)
                    #endif
            }

            Button {
                submitAdminLogin()
            } label: {
                HStack {
                    if isSubmitting {
                        ProgressView().tint(PremiumTheme.background)
                    }
                    Text("Sign In")
                        .font(.body.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
            }
            .psychosocialPrimaryButton()
            .disabled(isSubmitting || email.trimmingCharacters(in: .whitespaces).isEmpty || password.isEmpty)
            .opacity(isSubmitting || email.trimmingCharacters(in: .whitespaces).isEmpty || password.isEmpty ? 0.6 : 1)

            Text("Default admin credentials: admin@psychosocialanalytics.com / admin123")
                .font(.caption2)
                .foregroundStyle(PremiumTheme.textTertiary)
        }
    }

    private func submitPublicLogin() {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSubmitting = true
        errorMessage = nil

        let name = displayName.trimmingCharacters(in: .whitespaces).isEmpty
            ? email.components(separatedBy: "@").first ?? "User"
            : displayName

        access.updateUser(
            role: selectedRole,
            tier: .professional,
            isActive: true
        )
        access.updateEmail(email)
        access.updateDisplayName(name)

        isSubmitting = false
        onAuthenticated()
    }

    private func submitAdminLogin() {
        isSubmitting = true
        errorMessage = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let trimmedEmail = email.trimmingCharacters(in: .whitespaces).lowercased()
            let trimmedPassword = password.trimmingCharacters(in: .whitespaces)

            if trimmedEmail == "admin@psychosocialanalytics.com" && trimmedPassword == "admin123" {
                access.promoteToAdministrator()
                access.updateEmail(trimmedEmail)
                access.updateDisplayName("Administrator")
                isSubmitting = false
                onAuthenticated()
            } else {
                errorMessage = "Invalid administrator credentials. Please try again."
                isSubmitting = false
            }
        }
    }
}

extension View {
    func textFieldStyle() -> some View {
        self
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(PremiumTheme.surface, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(PremiumTheme.border, lineWidth: 1)
            )
            .foregroundStyle(PremiumTheme.textPrimary)
            .tint(PremiumTheme.emerald)
    }
}
