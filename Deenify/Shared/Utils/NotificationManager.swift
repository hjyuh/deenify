//
//  NotificationManager.swift
//  Deenify - Smart Notification System
//
//  Dual notification system for lessons and wisdom
//

import Foundation
import UserNotifications

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false

    private let center = UNUserNotificationCenter.current()

    private init() {
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    func requestAuthorization() async {
        do {
            isAuthorized = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            print("Error requesting notification authorization: \(error)")
        }
    }

    private func checkAuthorizationStatus() {
        Task {
            let settings = await center.notificationSettings()
            isAuthorized = settings.authorizationStatus == .authorized
        }
    }

    // MARK: - Schedule Daily Notifications

    func scheduleDailyNotifications() async {
        guard isAuthorized else { return }

        // Clear existing notifications
        center.removeAllPendingNotificationRequests()

        // Schedule lesson notification (7 AM)
        await scheduleLessonNotification()

        // Schedule wisdom notification (9 PM)
        await scheduleWisdomNotification()
    }

    private func scheduleLessonNotification() async {
        let content = UNMutableNotificationContent()
        content.title = "Your Daily Lesson Awaits"
        content.body = await getLessonNotificationBody()
        content.sound = .default
        content.categoryIdentifier = "LESSON_REMINDER"
        content.badge = 1

        // Schedule for 7 AM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 7
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily_lesson",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Error scheduling lesson notification: \(error)")
        }
    }

    private func scheduleWisdomNotification() async {
        let content = UNMutableNotificationContent()
        content.title = "Daily Wisdom"
        content.body = await getWisdomNotificationBody()
        content.sound = .default
        content.categoryIdentifier = "WISDOM_REMINDER"

        // Schedule for 9 PM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 21
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily_wisdom",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Error scheduling wisdom notification: \(error)")
        }
    }

    // MARK: - Smart Notification Copy

    private func getLessonNotificationBody() async -> String {
        let streak = UserProgress.shared.streak.lessonStreak
        let isCritical = UserProgress.shared.streak.isCritical

        if isCritical && streak > 0 {
            return "Don't lose your \(streak)-day streak! Complete your lesson now 🔥"
        } else if streak >= 7 {
            return "Keep your \(streak)-day streak alive! Just 5 minutes today ⏰"
        } else {
            return "Take 5 minutes to grow closer to Allah ✨"
        }
    }

    private func getWisdomNotificationBody() async -> String {
        // Get today's wisdom type
        let daysSinceEpoch = Calendar.current.dateComponents([.day], from: Date(timeIntervalSince1970: 0), to: Date()).day ?? 0
        let dayInCycle = (daysSinceEpoch % 7) + 1

        let wisdomTypes = [
            "Discover a Name of Allah 🌟",
            "Learn a powerful Dua 🤲",
            "Reflect on a Quranic verse 📖",
            "Wisdom from a Hadith 💬",
            "A story from the Prophets 📚",
            "Practical Islamic tip 💡",
            "Words from our scholars 🎓"
        ]

        return wisdomTypes[dayInCycle - 1]
    }

    // MARK: - Context-Specific Notifications

    func sendStreakBrokenNotification(type: StreakManager.StreakType) async {
        let content = UNMutableNotificationContent()
        content.title = type == .lesson ? "Lesson Streak Broken" : "Wisdom Streak Broken"
        content.body = "Don't worry! Today is a fresh start. Begin again 🌅"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        try? await center.add(request)
    }

    func sendStreakMilestoneNotification(streak: Int, type: StreakManager.StreakType) async {
        guard [7, 14, 21, 30, 50, 100].contains(streak) else { return }

        let content = UNMutableNotificationContent()
        content.title = "🎉 Milestone Achieved!"

        switch streak {
        case 7:
            content.body = "1 week of consistency! Keep going!"
        case 14:
            content.body = "2 weeks strong! You're unstoppable!"
        case 21:
            content.body = "21 days! You're building a lasting habit!"
        case 30:
            content.body = "1 month streak! Incredible dedication!"
        case 50:
            content.body = "50 days! You're an inspiration!"
        case 100:
            content.body = "100 DAYS! Mashallah, what an achievement! 👑"
        default:
            break
        }

        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        try? await center.add(request)
    }

    func sendPremiumConversionNotification() async {
        let content = UNMutableNotificationContent()
        content.title = "You've been using Deenify for 30 days! 🎉"
        content.body = "Unlock the full library with Premium. Your spiritual growth awaits."
        content.sound = .default
        content.categoryIdentifier = "PREMIUM_OFFER"

        let request = UNNotificationRequest(
            identifier: "premium_conversion",
            content: content,
            trigger: nil
        )

        try? await center.add(request)
    }

    // MARK: - Streak Recovery Notification

    func sendStreakRecoveryNotification(daysLost: Int) async {
        guard daysLost <= 2 else { return }

        let content = UNMutableNotificationContent()
        content.title = "We miss you! 🌙"
        content.body = "Your wisdom streak is waiting. Come back and continue your journey."
        content.sound = .default

        // Send after 24 hours of inactivity
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: false)
        let request = UNNotificationRequest(
            identifier: "streak_recovery",
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }

    // MARK: - Badge Management

    func updateBadgeCount(_ count: Int) {
        UNUserNotificationCenter.current().setBadgeCount(count)
    }

    func clearBadge() {
        updateBadgeCount(0)
    }
}

// MARK: - Notification Categories

extension NotificationManager {
    func setupNotificationCategories() {
        // Lesson reminder actions
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_LESSON",
            title: "Start Lesson",
            options: [.foreground]
        )

        let remindLaterAction = UNNotificationAction(
            identifier: "REMIND_LATER",
            title: "Remind me in 1 hour",
            options: []
        )

        let lessonCategory = UNNotificationCategory(
            identifier: "LESSON_REMINDER",
            actions: [completeAction, remindLaterAction],
            intentIdentifiers: [],
            options: []
        )

        // Wisdom reminder actions
        let viewWisdomAction = UNNotificationAction(
            identifier: "VIEW_WISDOM",
            title: "View Wisdom",
            options: [.foreground]
        )

        let wisdomCategory = UNNotificationCategory(
            identifier: "WISDOM_REMINDER",
            actions: [viewWisdomAction, remindLaterAction],
            intentIdentifiers: [],
            options: []
        )

        // Premium offer actions
        let viewPremiumAction = UNNotificationAction(
            identifier: "VIEW_PREMIUM",
            title: "Learn More",
            options: [.foreground]
        )

        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Maybe Later",
            options: []
        )

        let premiumCategory = UNNotificationCategory(
            identifier: "PREMIUM_OFFER",
            actions: [viewPremiumAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        center.setNotificationCategories([lessonCategory, wisdomCategory, premiumCategory])
    }
}

// MARK: - UNUserNotificationCenterDelegate

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.actionIdentifier

        switch identifier {
        case "COMPLETE_LESSON", "VIEW_WISDOM", "VIEW_PREMIUM":
            // Handle navigation via deep linking
            handleDeepLink(for: response.notification.request.content.categoryIdentifier)

        case "REMIND_LATER":
            // Schedule reminder in 1 hour
            Task {
                await scheduleReminder(in: 3600)
            }

        default:
            break
        }

        completionHandler()
    }

    private func handleDeepLink(for category: String) {
        // Implement deep linking to specific screens
        NotificationCenter.default.post(
            name: NSNotification.Name("OpenFromNotification"),
            object: nil,
            userInfo: ["category": category]
        )
    }

    private func scheduleReminder(in seconds: TimeInterval) async {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "Don't forget your daily lesson! ⏰"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
    }
}
