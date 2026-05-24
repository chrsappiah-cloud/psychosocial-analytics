import SwiftUI

// MARK: - Ambient background

public struct AmbientBackground: View {
    public init() {}

    public var body: some View {
        ZStack {
            PremiumTheme.background
            Circle()
                .fill(PremiumTheme.emerald.opacity(0.14))
                .frame(width: 320, height: 320)
                .blur(radius: 80)
                .offset(x: -120, y: -200)
            Circle()
                .fill(PremiumTheme.premiumGold.opacity(0.08))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(x: 140, y: 120)
            Circle()
                .fill(PremiumTheme.info.opacity(0.06))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .offset(x: 80, y: -80)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Brand header

public enum AppBrandHeaderStyle {
    case hero
    case compact
}

public struct AppBrandHeader: View {
    public let style: AppBrandHeaderStyle
    public var screenTitle: String?

    public init(style: AppBrandHeaderStyle, screenTitle: String? = nil) {
        self.style = style
        self.screenTitle = screenTitle
    }

    public var body: some View {
        switch style {
        case .hero: heroHeader
        case .compact: compactHeader
        }
    }

    private var heroHeader: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 0)
                    .fill(AppBrand.heroGradient)
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(
                                LinearGradient(
                                    colors: [PremiumTheme.emerald.opacity(0.35), .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    )

                VStack(spacing: 14) {
                    BrandMark(size: 64)
                    VStack(spacing: 4) {
                        Text(AppBrand.nameLine1)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(PremiumTheme.textPrimary)
                        Text(AppBrand.nameLine2)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(AppBrand.nameGradient)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier(AccessibilityID.appBrandTitle)
                    .accessibilityLabel(AppBrand.name)

                    Text(AppBrand.tagline)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(PremiumTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 24)
                .padding(.horizontal, 20)
            }
        }
    }

    private var compactHeader: some View {
        HStack(alignment: .center, spacing: 14) {
            BrandMark(size: 44)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 0) {
                    Text(AppBrand.nameLine1)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(PremiumTheme.textPrimary)
                    Text(" ")
                    Text(AppBrand.nameLine2)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(AppBrand.nameGradient)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier(AccessibilityID.appBrandTitle)
                .accessibilityLabel(AppBrand.name)

                if let screenTitle {
                    Text(screenTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(PremiumTheme.emeraldLight)
                } else {
                    Text(AppBrand.shortTagline)
                        .font(.caption2)
                        .foregroundStyle(PremiumTheme.textTertiary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            PremiumTheme.surface.opacity(0.85),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(PremiumTheme.border, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

public struct BrandMark: View {
    public let size: CGFloat

    public init(size: CGFloat = 48) {
        self.size = size
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(AppBrand.accentRingGradient, lineWidth: 2.5)
                .frame(width: size, height: size)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [PremiumTheme.surfaceElevated, PremiumTheme.surface],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size - 6, height: size - 6)
            Image(systemName: "brain.head.profile")
                .font(.system(size: size * 0.38, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [PremiumTheme.emeraldLight, PremiumTheme.emerald],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .shadow(color: PremiumTheme.emerald.opacity(0.25), radius: 12, y: 4)
    }
}

// MARK: - Screen chrome

public struct BrandedSectionTitle: View {
    public let title: String
    public var subtitle: String?

    public init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(PremiumTheme.textPrimary)
            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(PremiumTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

public struct BrandedScreenChrome<Content: View>: View {
    public let headerStyle: AppBrandHeaderStyle
    public var screenTitle: String?
    @ViewBuilder public var content: () -> Content

    public init(
        headerStyle: AppBrandHeaderStyle,
        screenTitle: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.headerStyle = headerStyle
        self.screenTitle = screenTitle
        self.content = content
    }

    public var body: some View {
        ZStack {
            AmbientBackground()
            VStack(spacing: 0) {
                AppBrandHeader(style: headerStyle, screenTitle: screenTitle)
                content()
            }
        }
        .psychosocialScreen()
    }
}

// MARK: - Enhanced cards & rows

public struct PremiumMetricCard: View {
    public let title: String
    public let value: String
    public let color: Color
    public let icon: String

    public init(title: String, value: String, color: Color, icon: String) {
        self.title = title
        self.value = value
        self.color = color
        self.icon = icon
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                Spacer()
            }
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(PremiumTheme.textSecondary)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PremiumTheme.surfaceElevated, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(PremiumTheme.border, lineWidth: 1)
        )
        .shadow(color: color.opacity(0.12), radius: 8, y: 4)
    }
}

public struct PremiumListRow: View {
    public let icon: String
    public let title: String
    public let subtitle: String
    public var accent: Color = PremiumTheme.emerald

    public var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3.weight(.semibold))
                .foregroundStyle(accent)
                .frame(width: 40, height: 40)
                .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(PremiumTheme.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(PremiumTheme.textSecondary)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(PremiumTheme.textTertiary)
        }
        .padding(.vertical, 6)
    }
}
