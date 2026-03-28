//
//  DailyWisdomView.swift
//  Deenify - Daily Wisdom Feature
//
//  Beautiful, shareable wisdom cards
//

import SwiftUI
import Combine

struct DailyWisdomView: View {
    @StateObject private var viewModel = DailyWisdomViewModel()
    @EnvironmentObject var userProgress: UserProgress
    @Namespace private var animation

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [AppColor.background, AppColor.background.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    // Header
                    wisdomHeader

                    // Main wisdom card
                    if let wisdom = viewModel.todaysWisdom {
                        WisdomCardView(wisdom: wisdom, namespace: animation)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else {
                        loadingView
                    }

                    Spacer()

                    // Action buttons
                    actionButtons
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("Daily Wisdom")
                            .font(.headline)
                        Text("\(viewModel.currentDayInCycle)/7")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .task {
            await viewModel.loadTodaysWisdom()
            await userProgress.recordWisdomView()
        }
    }

    // MARK: - Components

    private var wisdomHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Wisdom")
                    .font(.title2.bold())
                    .foregroundColor(AppColor.text)

                Text(viewModel.todaysWisdom?.type.rawValue ?? "Loading...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Wisdom streak badge
            StreakBadge(
                count: userProgress.streak.wisdomStreak,
                type: .wisdom
            )
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Bookmark button
            ActionButton(
                icon: userProgress.isBookmarked(viewModel.todaysWisdom?.id ?? UUID()) ? "bookmark.fill" : "bookmark",
                color: .orange,
                action: {
                    withAnimation(.spring()) {
                        toggleBookmark()
                    }
                }
            )

            // Share button
            ActionButton(
                icon: "square.and.arrow.up",
                color: .blue,
                action: {
                    shareWisdom()
                }
            )
            .matchedGeometryEffect(id: "shareButton", in: animation)

            // View archive (Premium)
            ActionButton(
                icon: "calendar",
                color: .purple,
                action: {
                    viewModel.showArchive = true
                }
            )
        }
        .padding(.horizontal)
    }

    private var loadingView: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(AppColor.cardBackground)
            .frame(maxWidth: .infinity)
            .frame(height: 450)
            .overlay {
                ProgressView()
                    .scaleEffect(1.5)
            }
    }

    // MARK: - Actions

    private func toggleBookmark() {
        guard let wisdom = viewModel.todaysWisdom else { return }

        if userProgress.isBookmarked(wisdom.id) {
            userProgress.removeBookmark(wisdomCardId: wisdom.id)
            HapticManager.shared.notification(.success)
        } else {
            // Check if user hit free limit
            let freeLimit = 5
            let isPremium = false // TODO: Get from user state

            if !isPremium && userProgress.bookmarks.count >= freeLimit {
                viewModel.showPremiumPrompt = true
            } else {
                userProgress.addBookmark(wisdom)
                HapticManager.shared.notification(.success)
            }
        }
    }

    private func shareWisdom() {
        guard let wisdom = viewModel.todaysWisdom else { return }

        // Generate beautiful share image
        let renderer = ImageRenderer(content: WisdomShareCard(wisdom: wisdom))
        renderer.scale = 3.0

        if let image = renderer.uiImage {
            let activityVC = UIActivityViewController(
                activityItems: [image, "Shared via Deenify - Your daily Islamic wisdom 🌙"],
                applicationActivities: nil
            )

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                rootVC.present(activityVC, animated: true)
            }

            // Track share event
            Task {
                await viewModel.trackShare()
            }
        }
    }
}

// MARK: - Wisdom Card View

struct WisdomCardView: View {
    let wisdom: WisdomCard
    let namespace: Namespace.ID

    @State private var isFlipped = false

    var body: some View {
        ZStack {
            // Card background with gradient
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [wisdom.type.color.opacity(0.1), wisdom.type.color.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: wisdom.type.color.opacity(0.2), radius: 20, y: 10)

            VStack(spacing: 20) {
                // Type badge
                HStack {
                    Label(wisdom.type.rawValue, systemImage: wisdom.type.icon)
                        .font(.caption.bold())
                        .foregroundColor(wisdom.type.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(wisdom.type.color.opacity(0.1))
                        .clipShape(Capsule())

                    Spacer()

                    if wisdom.isPremium {
                        PremiumBadge()
                    }
                }

                Spacer()

                // Arabic text (if available)
                if !wisdom.arabicText.isEmpty {
                    Text(wisdom.arabicText)
                        .font(.custom("AmiriQuran", size: 32))
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppColor.text)
                        .padding(.horizontal)
                        .lineSpacing(8)
                }

                // Transliteration
                if let transliteration = wisdom.transliteration {
                    Text(transliteration)
                        .font(.system(.body, design: .serif))
                        .italic()
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }

                Divider()
                    .padding(.horizontal, 40)

                // Translation
                Text(wisdom.translation)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppColor.text)
                    .padding(.horizontal)

                // Explanation
                Text(wisdom.explanation)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .lineLimit(4)

                Spacer()

                // Source
                if let source = wisdom.source {
                    Text(source)
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.7))
                }
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 500)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isFlipped.toggle()
            }
        }
    }
}

// MARK: - Share Card (for social media)

struct WisdomShareCard: View {
    let wisdom: WisdomCard

    var body: some View {
        ZStack {
            // Beautiful gradient background
            LinearGradient(
                colors: [
                    Color(hex: "1A1A2E"),
                    Color(hex: "16213E"),
                    Color(hex: "0F3460")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Decorative pattern
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    path.move(to: CGPoint(x: width * 0.8, y: 0))
                    path.addCurve(
                        to: CGPoint(x: width, y: height * 0.3),
                        control1: CGPoint(x: width * 0.9, y: height * 0.1),
                        control2: CGPoint(x: width * 0.95, y: height * 0.2)
                    )
                    path.addLine(to: CGPoint(x: width, y: 0))
                    path.closeSubpath()
                }
                .fill(LinearGradient(
                    colors: [wisdom.type.color.opacity(0.3), Color.clear],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                ))
            }

            VStack(spacing: 24) {
                Spacer()

                // Content
                VStack(spacing: 16) {
                    if !wisdom.arabicText.isEmpty {
                        Text(wisdom.arabicText)
                            .font(.custom("AmiriQuran", size: 36))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                    }

                    Text(wisdom.translation)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal)

                    if let source = wisdom.source {
                        Text(source)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }

                Spacer()

                // Branding
                HStack(spacing: 8) {
                    Image(systemName: "moon.stars.fill")
                        .foregroundColor(AppColor.gold)
                    Text("Deenify")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 32)
            }
            .padding(32)
        }
        .frame(width: 1080, height: 1920) // Instagram Story dimensions
    }
}

// MARK: - Supporting Views

struct StreakBadge: View {
    let count: Int
    let type: StreakType

    enum StreakType {
        case lesson, wisdom

        var icon: String {
            switch self {
            case .lesson: return "flame.fill"
            case .wisdom: return "sparkles"
            }
        }

        var color: Color {
            switch self {
            case .lesson: return .orange
            case .wisdom: return .purple
            }
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: type.icon)
                .font(.caption)
            Text("\(count)")
                .font(.headline)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(type.color)
        .clipShape(Capsule())
        .shadow(color: type.color.opacity(0.3), radius: 4, y: 2)
    }
}

struct ActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.impact(.medium)
            action()
        }) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(color)
                .clipShape(Circle())
                .shadow(color: color.opacity(0.3), radius: 8, y: 4)
        }
    }
}

struct PremiumBadge: View {
    var body: some View {
        Image(systemName: "crown.fill")
            .font(.caption)
            .foregroundColor(AppColor.gold)
            .padding(6)
            .background(AppColor.gold.opacity(0.1))
            .clipShape(Circle())
    }
}

// MARK: - View Model

@MainActor
class DailyWisdomViewModel: ObservableObject {
    @Published var todaysWisdom: WisdomCard?
    @Published var currentDayInCycle: Int = 1
    @Published var showArchive = false
    @Published var showPremiumPrompt = false

    private let wisdomRepository = WisdomRepository.shared

    func loadTodaysWisdom() async {
        // Calculate which day of the 7-day cycle we're on
        let daysSinceEpoch = Calendar.current.dateComponents([.day], from: Date(timeIntervalSince1970: 0), to: Date()).day ?? 0
        currentDayInCycle = (daysSinceEpoch % 7) + 1

        // Fetch wisdom for today
        todaysWisdom = await wisdomRepository.fetchWisdom(forDay: currentDayInCycle)
    }

    func trackShare() async {
        // Analytics: track share event
        await AnalyticsManager.shared.track(event: "wisdom_shared", properties: [
            "wisdom_type": todaysWisdom?.type.rawValue ?? "unknown",
            "day_in_cycle": currentDayInCycle
        ])
    }
}
