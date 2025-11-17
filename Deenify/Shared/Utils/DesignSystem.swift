//
//  DesignSystem.swift
//  Deenify - Complete Design System
//
//  Colors, Typography, Spacing, Components
//

import SwiftUI

// MARK: - Color Palette

enum AppColor {
    static let primary = Color("Teal", bundle: .main, fallback: Color(hex: "0D9488"))
    static let secondary = Color("Gold", bundle: .main, fallback: Color(hex: "D4AF37"))
    static let background = Color("Cream", bundle: .main, fallback: Color(hex: "FFFEF7"))
    static let cardBackground = Color("CardBG", bundle: .main, fallback: .white)
    static let text = Color("Charcoal", bundle: .main, fallback: Color(hex: "1F2937"))
    static let success = Color("Success", bundle: .main, fallback: Color(hex: "10B981"))
    static let warning = Color("Warning", bundle: .main, fallback: Color(hex: "F59E0B"))
    static let error = Color("Error", bundle: .main, fallback: Color(hex: "EF4444"))
    static let gold = Color(hex: "D4AF37")

    // Gradient colors for backgrounds
    static let gradientStart = Color(hex: "1A1A2E")
    static let gradientMiddle = Color(hex: "16213E")
    static let gradientEnd = Color(hex: "0F3460")
}

// MARK: - Typography

enum AppFont {
    // Arabic fonts
    static func arabic(size: CGFloat) -> Font {
        .custom("AmiriQuran-Regular", size: size)
    }

    static func arabicBold(size: CGFloat) -> Font {
        .custom("AmiriQuran-Bold", size: size)
    }

    // Latin fonts
    static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let title = Font.system(.title, design: .rounded).weight(.bold)
    static let title2 = Font.system(.title2, design: .rounded).weight(.semibold)
    static let title3 = Font.system(.title3, design: .rounded).weight(.semibold)
    static let headline = Font.system(.headline, design: .rounded).weight(.semibold)
    static let body = Font.system(.body, design: .default)
    static let bodyBold = Font.system(.body, design: .default).weight(.semibold)
    static let callout = Font.system(.callout, design: .default)
    static let subheadline = Font.system(.subheadline, design: .default)
    static let footnote = Font.system(.footnote, design: .default)
    static let caption = Font.system(.caption, design: .default)
}

// MARK: - Spacing

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius

enum CornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xlarge: CGFloat = 24
}

// MARK: - Shadow

enum AppShadow {
    static func small(color: Color = .black.opacity(0.1)) -> some View {
        EmptyView().shadow(color: color, radius: 4, y: 2)
    }

    static func medium(color: Color = .black.opacity(0.15)) -> some View {
        EmptyView().shadow(color: color, radius: 8, y: 4)
    }

    static func large(color: Color = .black.opacity(0.2)) -> some View {
        EmptyView().shadow(color: color, radius: 16, y: 8)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    init(_ name: String, bundle: Bundle? = nil, fallback: Color) {
        if let color = UIColor(named: name, in: bundle, compatibleWith: nil) {
            self.init(color)
        } else {
            self = fallback
        }
    }
}

// MARK: - Reusable Components

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false

    init(
        _ title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticManager.shared.impact(.medium)
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                    }
                    Text(title)
                        .font(AppFont.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isDisabled ? Color.gray : AppColor.primary)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        }
        .disabled(isDisabled || isLoading)
    }
}

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticManager.shared.impact(.light)
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(AppFont.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColor.primary.opacity(0.1))
            .foregroundColor(AppColor.primary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading...")
                .font(AppFont.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.secondary.opacity(0.5))

            VStack(spacing: 8) {
                Text(title)
                    .font(AppFont.title3)
                    .foregroundColor(AppColor.text)

                Text(message)
                    .font(AppFont.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(actionTitle, action: action)
                    .padding(.horizontal, 40)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorView: View {
    let error: String
    let retry: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundColor(AppColor.error)

            VStack(spacing: 8) {
                Text("Something went wrong")
                    .font(AppFont.title3)
                    .foregroundColor(AppColor.text)

                Text(error)
                    .font(AppFont.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let retry = retry {
                PrimaryButton("Try Again", icon: "arrow.clockwise", action: retry)
                    .padding(.horizontal, 40)
            }
        }
        .padding()
    }
}

struct SplashView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColor.gradientStart, AppColor.gradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppColor.gold)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)

                Text("Deenify")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Your daily spiritual companion")
                    .font(AppFont.body)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle() -> some View {
        self
            .background(AppColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width)
                    .offset(x: phase * geometry.size.width)
                }
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// MARK: - Haptic Manager

class HapticManager {
    static let shared = HapticManager()

    private init() {}

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
