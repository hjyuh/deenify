//
//  StreakManager.swift
//  Deenify - Streak Tracking & Management
//

import Foundation
import SwiftUI

@MainActor
class StreakManager: ObservableObject {
    @Published var lessonStreak: Int = 0
    @Published var wisdomStreak: Int = 0
    @Published var isCritical: Bool = false
    @Published var showStreakSavedCelebration: Bool = false

    private let userProgress = UserProgress.shared

    init() {
        loadStreaks()
    }

    func checkAndUpdateStreaks() async {
        let calendar = Calendar.current
        let today = Date()

        // Check lesson streak
        if let lastLessonDate = userProgress.streak.lastLessonDate {
            let daysSinceLastLesson = calendar.dateComponents([.day], from: lastLessonDate, to: today).day ?? 0

            if daysSinceLastLesson > 1 {
                // Streak broken
                await breakStreak(type: .lesson)
            } else if daysSinceLastLesson == 1 {
                // Streak is at risk
                isCritical = true
            }
        }

        // Check wisdom streak
        if let lastWisdomDate = userProgress.streak.lastWisdomDate {
            let daysSinceLastWisdom = calendar.dateComponents([.day], from: lastWisdomDate, to: today).day ?? 0

            if daysSinceLastWisdom > 1 {
                await breakStreak(type: .wisdom)
            }
        }

        loadStreaks()
    }

    private func breakStreak(type: StreakType) async {
        switch type {
        case .lesson:
            userProgress.streak.lessonStreak = 0
        case .wisdom:
            userProgress.streak.wisdomStreak = 0
        }

        // Send notification about broken streak
        await NotificationManager.shared.sendStreakBrokenNotification(type: type)
    }

    func incrementStreak(type: StreakType) {
        withAnimation(.spring()) {
            switch type {
            case .lesson:
                lessonStreak += 1
                userProgress.streak.lessonStreak = lessonStreak
                userProgress.streak.longestLessonStreak = max(
                    lessonStreak,
                    userProgress.streak.longestLessonStreak
                )
            case .wisdom:
                wisdomStreak += 1
                userProgress.streak.wisdomStreak = wisdomStreak
                userProgress.streak.longestWisdomStreak = max(
                    wisdomStreak,
                    userProgress.streak.longestWisdomStreak
                )
            }

            isCritical = false
            showStreakSavedCelebration = true

            HapticManager.shared.notification(.success)
        }

        // Hide celebration after 2 seconds
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                showStreakSavedCelebration = false
            }
        }
    }

    private func loadStreaks() {
        lessonStreak = userProgress.streak.lessonStreak
        wisdomStreak = userProgress.streak.wisdomStreak
    }

    enum StreakType {
        case lesson, wisdom
    }
}

// MARK: - Streak Dashboard View

struct StreakDashboardView: View {
    @ObservedObject var streakManager: StreakManager

    var body: some View {
        VStack(spacing: 16) {
            // Lesson Streak Card
            StreakCard(
                title: "Lesson Streak",
                icon: "flame.fill",
                count: streakManager.lessonStreak,
                longest: UserProgress.shared.streak.longestLessonStreak,
                color: .orange,
                isCritical: streakManager.isCritical
            )

            // Wisdom Streak Card
            StreakCard(
                title: "Wisdom Streak",
                icon: "sparkles",
                count: streakManager.wisdomStreak,
                longest: UserProgress.shared.streak.longestWisdomStreak,
                color: .purple,
                isCritical: false
            )

            // Motivational message
            if streakManager.isCritical {
                CriticalStreakBanner()
            } else if streakManager.lessonStreak >= 7 {
                MotivationalBanner(streak: streakManager.lessonStreak)
            }
        }
        .padding()
    }
}

struct StreakCard: View {
    let title: String
    let icon: String
    let count: Int
    let longest: Int
    let color: Color
    let isCritical: Bool

    var body: some View {
        HStack {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 60, height: 60)

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(count)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(color)

                    Text("days")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Text("Longest: \(longest) days")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isCritical {
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("At Risk!")
                        .font(.caption.bold())
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

struct CriticalStreakBanner: View {
    var body: some View {
        HStack {
            Image(systemName: "flame.fill")
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 2) {
                Text("Don't lose your streak!")
                    .font(.headline)
                    .foregroundColor(.white)

                Text("Complete a lesson today to keep it going")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.red, .orange],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct MotivationalBanner: View {
    let streak: Int

    var message: String {
        switch streak {
        case 7: return "1 week strong! 🎉"
        case 14: return "2 weeks of consistency! 💪"
        case 21: return "21 days! You're building a habit! 🌟"
        case 30: return "1 month streak! Incredible! 🔥"
        case 100: return "100 days! You're unstoppable! 👑"
        default: return "Keep going! You're doing amazing! ✨"
        }
    }

    var body: some View {
        HStack {
            Text(message)
                .font(.subheadline.bold())
                .foregroundColor(.white)

            Spacer()

            Image(systemName: "hands.clap.fill")
                .foregroundColor(.white)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [AppColor.primary, AppColor.secondary],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Streak Celebration View

struct StreakCelebrationView: View {
    let streakCount: Int
    let type: StreakManager.StreakType

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Confetti effect
            ForEach(0..<20) { index in
                Circle()
                    .fill(Color.random)
                    .frame(width: 8, height: 8)
                    .offset(
                        x: isAnimating ? CGFloat.random(in: -200...200) : 0,
                        y: isAnimating ? CGFloat.random(in: -300...0) : 0
                    )
                    .opacity(isAnimating ? 0 : 1)
            }

            VStack(spacing: 16) {
                Image(systemName: type == .lesson ? "flame.fill" : "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(type == .lesson ? .orange : .purple)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)

                Text("\(streakCount) Day Streak!")
                    .font(.title.bold())

                Text("The most regular constant deeds, even though they may be few")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(32)
            .background(AppColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(radius: 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).repeatCount(3)) {
                isAnimating = true
            }

            HapticManager.shared.notification(.success)
        }
    }
}

// MARK: - Color Extension

extension Color {
    static var random: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
