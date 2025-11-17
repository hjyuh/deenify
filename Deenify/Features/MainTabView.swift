//
//  MainTabView.swift
//  Deenify - Main App Navigation
//

import SwiftUI
import Combine

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Daily Wisdom Tab
            DailyWisdomView()
                .tabItem {
                    Label("Wisdom", systemImage: "sparkles")
                }
                .tag(0)

            // Lessons Tab
            LessonsView()
                .tabItem {
                    Label("Lessons", systemImage: "book.fill")
                }
                .tag(1)

            // Progress Tab
            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)

            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(AppColor.primary)
    }
}

// MARK: - Lessons View

struct LessonsView: View {
    @StateObject private var viewModel = LessonsViewModel()
    @EnvironmentObject var streakManager: StreakManager

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Streak banner
                    if streakManager.isCritical {
                        CriticalStreakBanner()
                    }

                    // Learning paths
                    ForEach(viewModel.learningPaths) { path in
                        LearningPathCard(path: path)
                    }

                    Spacer(minLength: 100)
                }
                .padding()
            }
            .background(AppColor.background)
            .navigationTitle("Your Lessons")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await viewModel.loadLearningPaths()
        }
    }
}

struct LearningPathCard: View {
    let path: LearningPath

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: path.icon)
                    .font(.title2)
                    .foregroundColor(AppColor.primary)

                Text(path.title)
                    .font(AppFont.title3)
                    .foregroundColor(AppColor.text)

                Spacer()

                if path.isPremium {
                    PremiumBadge()
                }
            }

            Text(path.description)
                .font(AppFont.body)
                .foregroundColor(.secondary)
                .lineLimit(2)

            // Modules list
            ForEach(path.modules.prefix(3)) { module in
                NavigationLink(destination: ModuleDetailView(module: module)) {
                    ModuleRow(module: module)
                }
            }

            if path.modules.count > 3 {
                NavigationLink("View all \(path.modules.count) modules") {
                    PathDetailView(path: path)
                }
                .font(AppFont.callout)
                .foregroundColor(AppColor.primary)
            }
        }
        .padding()
        .cardStyle()
    }
}

struct ModuleRow: View {
    let module: LessonModule

    var body: some View {
        HStack {
            Circle()
                .fill(module.progress == 1.0 ? AppColor.success : AppColor.primary.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay {
                    if module.progress == 1.0 {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                    } else {
                        Text("\(module.lessons.count)")
                            .font(.caption.bold())
                            .foregroundColor(AppColor.primary)
                    }
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(module.title)
                    .font(AppFont.body)
                    .foregroundColor(AppColor.text)

                ProgressView(value: module.progress)
                    .tint(AppColor.primary)
            }

            Spacer()

            if module.isPremium {
                Image(systemName: "crown.fill")
                    .font(.caption)
                    .foregroundColor(AppColor.gold)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Progress View

struct ProgressView: View {
    @EnvironmentObject var streakManager: StreakManager
    @EnvironmentObject var userProgress: UserProgress

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Hasanat Card
                    HasanatCard(hasanat: userProgress.currentHasanat)

                    // Streaks
                    StreakDashboardView(streakManager: streakManager)

                    // Badges
                    if !userProgress.unlockedBadges.isEmpty {
                        BadgesSection(badges: userProgress.unlockedBadges)
                    }

                    Spacer()
                }
                .padding()
            }
            .background(AppColor.background)
            .navigationTitle("Your Progress")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct HasanatCard: View {
    let hasanat: Int

    var currentLevel: Int {
        hasanat / 1000 + 1
    }

    var progressToNextLevel: Double {
        Double(hasanat % 1000) / 1000.0
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hasanat (Good Deeds)")
                        .font(AppFont.subheadline)
                        .foregroundColor(.secondary)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(hasanat)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(AppColor.primary)

                        Text("points")
                            .font(AppFont.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                VStack {
                    Text("Level")
                        .font(AppFont.caption)
                        .foregroundColor(.secondary)

                    Text("\(currentLevel)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(AppColor.gold)
                }
                .padding()
                .background(AppColor.gold.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Progress to Level \(currentLevel + 1)")
                    .font(AppFont.caption)
                    .foregroundColor(.secondary)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppColor.primary.opacity(0.1))

                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppColor.primary)
                            .frame(width: geometry.size.width * progressToNextLevel)
                    }
                }
                .frame(height: 12)

                Text("\(1000 - (hasanat % 1000)) more to next level")
                    .font(AppFont.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .cardStyle()
    }
}

struct BadgesSection: View {
    let badges: [Badge]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Unlocked Badges")
                .font(AppFont.title3)
                .foregroundColor(AppColor.text)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(badges) { badge in
                    BadgeCard(badge: badge)
                }
            }
        }
    }
}

struct BadgeCard: View {
    let badge: Badge

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: badge.icon)
                .font(.system(size: 40))
                .foregroundColor(AppColor.gold)

            Text(badge.title)
                .font(AppFont.caption.bold())
                .foregroundColor(AppColor.text)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColor.gold.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Profile View

struct ProfileView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // User info
                    if let user = appState.currentUser {
                        UserProfileCard(user: user)
                    }

                    // Premium upgrade (if not premium)
                    if !(appState.currentUser?.isPremium ?? false) {
                        PremiumUpgradeCard()
                    }

                    // Settings
                    SettingsSection()

                    Spacer()
                }
                .padding()
            }
            .background(AppColor.background)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct UserProfileCard: View {
    let user: User

    var body: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(AppColor.primary.opacity(0.1))
                .frame(width: 80, height: 80)
                .overlay {
                    Text(user.name.prefix(1).uppercased())
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(AppColor.primary)
                }

            VStack(spacing: 4) {
                Text(user.name)
                    .font(AppFont.title3)
                    .foregroundColor(AppColor.text)

                if let email = user.email {
                    Text(email)
                        .font(AppFont.caption)
                        .foregroundColor(.secondary)
                }
            }

            if user.isPremium {
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                    Text("Premium Member")
                }
                .font(AppFont.caption.bold())
                .foregroundColor(AppColor.gold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppColor.gold.opacity(0.1))
                .clipShape(Capsule())
            }
        }
        .padding()
        .cardStyle()
    }
}

struct PremiumUpgradeCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundColor(AppColor.gold)

                Text("Upgrade to Premium")
                    .font(AppFont.title3)
                    .foregroundColor(.white)
            }

            Text("Unlock all lessons, unlimited bookmarks, and personalized learning")
                .font(AppFont.body)
                .foregroundColor(.white.opacity(0.9))

            PrimaryButton("Learn More") {
                // Show premium screen
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [AppColor.primary, AppColor.secondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }
}

struct SettingsSection: View {
    var body: some View {
        VStack(spacing: 0) {
            SettingsRow(icon: "bell.fill", title: "Notifications", action: {})
            Divider().padding(.leading, 60)

            SettingsRow(icon: "moon.fill", title: "Dark Mode", action: {})
            Divider().padding(.leading, 60)

            SettingsRow(icon: "lock.fill", title: "Privacy Policy", action: {})
            Divider().padding(.leading, 60)

            SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", action: {})
            Divider().padding(.leading, 60)

            SettingsRow(icon: "info.circle.fill", title: "About", action: {})
        }
        .cardStyle()
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(AppColor.primary)
                    .frame(width: 24)

                Text(title)
                    .font(AppFont.body)
                    .foregroundColor(AppColor.text)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

// MARK: - View Models

@MainActor
class LessonsViewModel: ObservableObject {
    @Published var learningPaths: [LearningPath] = []
    @Published var isLoading = false

    func loadLearningPaths() async {
        isLoading = true
        defer { isLoading = false }

        // TODO: Load from CloudKit
        // For now, create sample data
        learningPaths = createSamplePaths()
    }

    private func createSamplePaths() -> [LearningPath] {
        // Sample Dua Path
        let duaPath = LearningPath(
            id: UUID(),
            title: "Foundational Dua Path",
            description: "Learn daily supplications for every aspect of life",
            icon: "hands.sparkles.fill",
            modules: [],
            isPremium: false
        )

        return [duaPath]
    }
}

// MARK: - Supporting Views

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack {
            Text("Welcome to Deenify")
                .font(AppFont.largeTitle)

            PrimaryButton("Get Started") {
                appState.completeOnboarding()
            }
        }
    }
}

struct AuthenticationView: View {
    var body: some View {
        VStack {
            Text("Sign In")
                .font(AppFont.largeTitle)

            // Implement Sign in with Apple
        }
    }
}

struct PathDetailView: View {
    let path: LearningPath

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(path.modules) { module in
                    NavigationLink(destination: ModuleDetailView(module: module)) {
                        ModuleRow(module: module)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(path.title)
    }
}

struct ModuleDetailView: View {
    let module: LessonModule

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(module.lessons) { lesson in
                    NavigationLink(destination: LessonDetailView(lesson: lesson)) {
                        LessonRow(lesson: lesson)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(module.title)
    }
}

struct LessonRow: View {
    let lesson: Lesson

    var body: some View {
        HStack {
            Circle()
                .fill(lesson.isCompleted ? AppColor.success : AppColor.primary.opacity(0.1))
                .frame(width: 32, height: 32)
                .overlay {
                    if lesson.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    } else {
                        Text("\(lesson.orderIndex)")
                            .font(.caption.bold())
                            .foregroundColor(AppColor.primary)
                    }
                }

            Text(lesson.title)
                .font(AppFont.body)
                .foregroundColor(AppColor.text)

            Spacer()

            if lesson.isPremium {
                Image(systemName: "crown.fill")
                    .font(.caption)
                    .foregroundColor(AppColor.gold)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .cardStyle()
    }
}

struct LessonDetailView: View {
    let lesson: Lesson

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Lesson coming soon!")
                    .font(AppFont.title2)
            }
            .padding()
        }
        .navigationTitle(lesson.title)
    }
}
