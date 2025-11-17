//
//  Models.swift
//  Deenify - Core Domain Models
//

import Foundation
import SwiftUI
import Combine

// MARK: - User

struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String?
    var createdAt: Date
    var hasanat: Int // Total points earned
    var currentLevel: Int
    var premiumStatus: PremiumStatus

    var isPremium: Bool {
        premiumStatus == .active
    }

    enum PremiumStatus: String, Codable {
        case free
        case active
        case expired
    }
}

// MARK: - Wisdom Card

struct WisdomCard: Identifiable, Codable, Hashable {
    let id: UUID
    let type: WisdomType
    let dayInCycle: Int // 1-7
    let arabicText: String
    let transliteration: String?
    let translation: String
    let explanation: String
    let category: WisdomCategory
    let source: String? // e.g., "Tirmidhi", "Surah Ash-Sharh 94:6"
    var isPremium: Bool

    enum WisdomType: String, Codable, CaseIterable {
        case nameOfAllah = "Name of Allah"
        case quickDua = "Quick Dua"
        case quranicVerse = "Quranic Verse"
        case hadith = "Hadith"
        case propheticStory = "Prophetic Story"
        case practicalTip = "Practical Tip"
        case scholarReflection = "Scholar's Reflection"

        var icon: String {
            switch self {
            case .nameOfAllah: return "star.fill"
            case .quickDua: return "hands.sparkles"
            case .quranicVerse: return "book.fill"
            case .hadith: return "quote.bubble.fill"
            case .propheticStory: return "lightbulb.fill"
            case .practicalTip: return "checkmark.circle.fill"
            case .scholarReflection: return "graduationcap.fill"
            }
        }

        var color: Color {
            switch self {
            case .nameOfAllah: return .purple
            case .quickDua: return .blue
            case .quranicVerse: return .green
            case .hadith: return .orange
            case .propheticStory: return .pink
            case .practicalTip: return .teal
            case .scholarReflection: return .indigo
            }
        }
    }

    enum WisdomCategory: String, Codable, CaseIterable {
        case patience = "Patience"
        case gratitude = "Gratitude"
        case hardship = "Hardship"
        case mercy = "Mercy"
        case family = "Family"
        case worship = "Worship"
        case character = "Character"
        case knowledge = "Knowledge"
    }
}

// MARK: - Lesson

struct Lesson: Identifiable, Codable {
    let id: UUID
    let moduleId: UUID
    let orderIndex: Int
    let title: String
    let duaOrVerse: DuaContent
    let isPremium: Bool

    var isCompleted: Bool {
        UserProgress.shared.isLessonCompleted(id)
    }
}

struct DuaContent: Codable {
    let arabicText: String
    let transliteration: String
    let translation: String
    let context: String // The "Why" - reason for this dua
    let explanation: String // The "Heart" - Mini-Tafsir
    let audioURL: URL?
    let vocabulary: [VocabularyItem]
    let quiz: Quiz
}

struct VocabularyItem: Codable, Identifiable {
    let id: UUID
    let arabicWord: String
    let englishMeaning: String
}

struct Quiz: Codable {
    let questions: [QuizQuestion]
}

struct QuizQuestion: Codable, Identifiable {
    let id: UUID
    let question: String
    let options: [String]
    let correctAnswer: Int // Index of correct option
}

// MARK: - Module

struct LessonModule: Identifiable, Codable {
    let id: UUID
    let pathId: UUID // Dua Path or Verse Path
    let title: String
    let description: String
    let orderIndex: Int
    let icon: String
    let lessons: [Lesson]
    let isPremium: Bool

    var progress: Double {
        let completed = lessons.filter { $0.isCompleted }.count
        return lessons.isEmpty ? 0 : Double(completed) / Double(lessons.count)
    }
}

// MARK: - Learning Path

struct LearningPath: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let modules: [LessonModule]
    let isPremium: Bool

    enum PathType: String, Codable {
        case duaPath = "Foundational Dua Path"
        case versePath = "Quranic Verse Path"
    }
}

// MARK: - Streak

struct Streak: Codable {
    var lessonStreak: Int
    var wisdomStreak: Int
    var lastLessonDate: Date?
    var lastWisdomDate: Date?
    var longestLessonStreak: Int
    var longestWisdomStreak: Int

    var isCritical: Bool {
        // Streak is critical if user hasn't engaged today
        guard let lastLesson = lastLessonDate else { return true }
        return !Calendar.current.isDateInToday(lastLesson)
    }
}

// MARK: - Bookmark

struct Bookmark: Identifiable, Codable {
    let id: UUID
    let wisdomCardId: UUID
    let createdAt: Date
}

// MARK: - Badge

struct Badge: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let requirement: BadgeRequirement
    var isUnlocked: Bool
    let unlockedAt: Date?

    enum BadgeRequirement: Codable {
        case completeModule(moduleId: UUID)
        case achieveStreak(days: Int)
        case earnHasanat(points: Int)
        case shareWisdom(count: Int)
        case completeLessons(count: Int)
    }
}

// MARK: - User Progress (Singleton)

@MainActor
class UserProgress: ObservableObject {
    static let shared = UserProgress()

    @Published var completedLessons: Set<UUID> = []
    @Published var currentHasanat: Int = 0
    @Published var streak: Streak = Streak(
        lessonStreak: 0,
        wisdomStreak: 0,
        longestLessonStreak: 0,
        longestWisdomStreak: 0
    )
    @Published var bookmarks: [Bookmark] = []
    @Published var unlockedBadges: [Badge] = []

    private let userDefaults = UserDefaults.standard
    private let cloudKitManager = CloudKitManager.shared

    private init() {
        loadFromUserDefaults()
    }

    func isLessonCompleted(_ lessonId: UUID) -> Bool {
        completedLessons.contains(lessonId)
    }

    func completeLesson(_ lessonId: UUID, hasanatEarned: Int) async {
        completedLessons.insert(lessonId)
        currentHasanat += hasanatEarned

        // Update streak
        let today = Date()
        if let lastDate = streak.lastLessonDate {
            if Calendar.current.isDate(lastDate, inSameDayAs: today) {
                // Already completed today, don't increment
            } else if Calendar.current.isDate(lastDate, equalTo: today.addingTimeInterval(-86400), toGranularity: .day) {
                // Completed yesterday, increment streak
                streak.lessonStreak += 1
                streak.longestLessonStreak = max(streak.longestLessonStreak, streak.lessonStreak)
            } else {
                // Streak broken
                streak.lessonStreak = 1
            }
        } else {
            streak.lessonStreak = 1
        }
        streak.lastLessonDate = today

        saveToUserDefaults()
        await syncToCloudKit()

        // Check for badge unlocks
        await checkBadgeUnlocks()
    }

    func recordWisdomView() async {
        let today = Date()
        if let lastDate = streak.lastWisdomDate {
            if Calendar.current.isDate(lastDate, inSameDayAs: today) {
                // Already viewed today
            } else if Calendar.current.isDate(lastDate, equalTo: today.addingTimeInterval(-86400), toGranularity: .day) {
                streak.wisdomStreak += 1
                streak.longestWisdomStreak = max(streak.longestWisdomStreak, streak.wisdomStreak)
            } else {
                streak.wisdomStreak = 1
            }
        } else {
            streak.wisdomStreak = 1
        }
        streak.lastWisdomDate = today

        saveToUserDefaults()
        await syncToCloudKit()
    }

    func addBookmark(_ wisdomCard: WisdomCard) {
        let bookmark = Bookmark(
            id: UUID(),
            wisdomCardId: wisdomCard.id,
            createdAt: Date()
        )
        bookmarks.append(bookmark)
        saveToUserDefaults()
    }

    func removeBookmark(wisdomCardId: UUID) {
        bookmarks.removeAll { $0.wisdomCardId == wisdomCardId }
        saveToUserDefaults()
    }

    func isBookmarked(_ wisdomCardId: UUID) -> Bool {
        bookmarks.contains { $0.wisdomCardId == wisdomCardId }
    }

    private func checkBadgeUnlocks() async {
        // Implementation for checking if user unlocked new badges
    }

    // MARK: - Persistence

    private func loadFromUserDefaults() {
        if let data = userDefaults.data(forKey: "userProgress"),
           let decoded = try? JSONDecoder().decode(UserProgressData.self, from: data) {
            self.completedLessons = Set(decoded.completedLessons)
            self.currentHasanat = decoded.currentHasanat
            self.streak = decoded.streak
            self.bookmarks = decoded.bookmarks
        }
    }

    private func saveToUserDefaults() {
        let data = UserProgressData(
            completedLessons: Array(completedLessons),
            currentHasanat: currentHasanat,
            streak: streak,
            bookmarks: bookmarks
        )
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults.set(encoded, forKey: "userProgress")
        }
    }

    private func syncToCloudKit() async {
        // Sync progress to CloudKit for backup (optional - works offline without it)
        #if DEBUG
        // Skip CloudKit sync in development if capability not enabled
        guard cloudKitManager.isAuthenticated else {
            print("⚠️ CloudKit not available - running in local-only mode")
            return
        }
        #endif

        await cloudKitManager.syncUserProgress(
            completedLessons: completedLessons,
            hasanat: currentHasanat,
            streak: streak
        )
    }
}

// Helper struct for Codable persistence
private struct UserProgressData: Codable {
    let completedLessons: [UUID]
    let currentHasanat: Int
    let streak: Streak
    let bookmarks: [Bookmark]
}
