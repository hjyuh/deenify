//
//  CloudKitManager.swift
//  Deenify - CloudKit Backend Manager
//
//  Handles all CloudKit operations: authentication, sync, data fetching
//

import Foundation
import CloudKit
import Combine

// Remove @MainActor to avoid initialization issues with singleton
class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()

    private var container: CKContainer?
    private var publicDatabase: CKDatabase?
    private var privateDatabase: CKDatabase?

    @Published var accountStatus: CKAccountStatus = .couldNotDetermine
    @Published var isAuthenticated = false

    // Flag to check if CloudKit is available
    private var cloudKitAvailable = false

    private init() {
        // In DEBUG mode, skip CloudKit completely
        // This allows running without Apple Developer account
        #if DEBUG
        print("🔧 DEBUG MODE: CloudKit disabled")
        print("📱 All data stored locally in UserDefaults")
        self.cloudKitAvailable = false
        self.container = nil
        self.publicDatabase = nil
        self.privateDatabase = nil
        #else
        // Production: CloudKit required
        self.container = CKContainer(identifier: "iCloud.com.deenify.app")
        self.publicDatabase = self.container?.publicCloudDatabase
        self.privateDatabase = self.container?.privateCloudDatabase
        self.cloudKitAvailable = true

        Task { @MainActor in
            await self.checkAccountStatus()
        }
        #endif
    }

    // MARK: - Authentication

    func checkAccountStatus() async -> Bool {
        guard cloudKitAvailable, let container = container else {
            return false
        }

        do {
            accountStatus = try await container.accountStatus()
            isAuthenticated = accountStatus == .available
            return isAuthenticated
        } catch {
            print("Error checking account status: \(error)")
            return false
        }
    }

    // MARK: - User Profile

    func fetchUserProfile() async -> User? {
        guard cloudKitAvailable, let container = container, let privateDatabase = privateDatabase else {
            return nil
        }

        do {
            let recordID = try await container.userRecordID()
            let record = try await privateDatabase.record(for: recordID)

            return User(
                id: UUID(uuidString: record["userID"] as? String ?? UUID().uuidString) ?? UUID(),
                name: record["name"] as? String ?? "User",
                email: record["email"] as? String,
                createdAt: record.creationDate ?? Date(),
                hasanat: record["hasanat"] as? Int ?? 0,
                currentLevel: record["level"] as? Int ?? 1,
                premiumStatus: User.PremiumStatus(rawValue: record["premiumStatus"] as? String ?? "free") ?? .free
            )
        } catch {
            print("Error fetching user profile: \(error)")
            return nil
        }
    }

    func createUserProfile(name: String, email: String?) async -> User? {
        guard cloudKitAvailable, let container = container, let privateDatabase = privateDatabase else {
            return nil
        }

        do {
            let recordID = try await container.userRecordID()
            let record = CKRecord(recordType: "UserProfile", recordID: recordID)

            let userId = UUID()
            record["userID"] = userId.uuidString
            record["name"] = name
            record["email"] = email
            record["hasanat"] = 0
            record["level"] = 1
            record["premiumStatus"] = "free"

            try await privateDatabase.save(record)

            return User(
                id: userId,
                name: name,
                email: email,
                createdAt: Date(),
                hasanat: 0,
                currentLevel: 1,
                premiumStatus: .free
            )
        } catch {
            print("Error creating user profile: \(error)")
            return nil
        }
    }

    // MARK: - Wisdom Cards

    func fetchWisdom(forDay day: Int) async -> WisdomCard? {
        guard cloudKitAvailable, let publicDatabase = publicDatabase else {
            return nil
        }

        let predicate = NSPredicate(format: "dayInCycle == %d", day)
        let query = CKQuery(recordType: "WisdomCard", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        do {
            let (results, _) = try await publicDatabase.records(matching: query, resultsLimit: 1)
            guard let (_, result) = results.first else { return nil }

            switch result {
            case .success(let record):
                return mapWisdomCard(from: record)
            case .failure(let error):
                print("Error fetching wisdom: \(error)")
                return nil
            }
        } catch {
            print("Error querying wisdom cards: \(error)")
            return nil
        }
    }

    func fetchAllWisdomCards() async -> [WisdomCard] {
        guard cloudKitAvailable, let publicDatabase = publicDatabase else {
            return []
        }

        let query = CKQuery(recordType: "WisdomCard", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "dayInCycle", ascending: true)]

        do {
            let (results, _) = try await publicDatabase.records(matching: query)
            return results.compactMap { _, result in
                switch result {
                case .success(let record):
                    return mapWisdomCard(from: record)
                case .failure:
                    return nil
                }
            }
        } catch {
            print("Error fetching all wisdom cards: \(error)")
            return []
        }
    }

    private func mapWisdomCard(from record: CKRecord) -> WisdomCard? {
        guard
            let id = UUID(uuidString: record["id"] as? String ?? ""),
            let typeRaw = record["type"] as? String,
            let type = WisdomCard.WisdomType(rawValue: typeRaw),
            let dayInCycle = record["dayInCycle"] as? Int,
            let arabicText = record["arabicText"] as? String,
            let translation = record["translation"] as? String,
            let explanation = record["explanation"] as? String,
            let categoryRaw = record["category"] as? String,
            let category = WisdomCard.WisdomCategory(rawValue: categoryRaw)
        else {
            return nil
        }

        return WisdomCard(
            id: id,
            type: type,
            dayInCycle: dayInCycle,
            arabicText: arabicText,
            transliteration: record["transliteration"] as? String,
            translation: translation,
            explanation: explanation,
            category: category,
            source: record["source"] as? String,
            isPremium: record["isPremium"] as? Bool ?? false
        )
    }

    // MARK: - Lessons

    func fetchLessons(forModuleId moduleId: UUID) async -> [Lesson] {
        guard cloudKitAvailable, let publicDatabase = publicDatabase else {
            return []
        }

        let predicate = NSPredicate(format: "moduleId == %@", moduleId.uuidString)
        let query = CKQuery(recordType: "Lesson", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]

        do {
            let (results, _) = try await publicDatabase.records(matching: query)
            return results.compactMap { _, result in
                switch result {
                case .success(let record):
                    return mapLesson(from: record)
                case .failure:
                    return nil
                }
            }
        } catch {
            print("Error fetching lessons: \(error)")
            return []
        }
    }

    private func mapLesson(from record: CKRecord) -> Lesson? {
        guard
            let id = UUID(uuidString: record["id"] as? String ?? ""),
            let moduleId = UUID(uuidString: record["moduleId"] as? String ?? ""),
            let orderIndex = record["orderIndex"] as? Int,
            let title = record["title"] as? String,
            let arabicText = record["arabicText"] as? String,
            let transliteration = record["transliteration"] as? String,
            let translation = record["translation"] as? String,
            let context = record["context"] as? String,
            let explanation = record["explanation"] as? String
        else {
            return nil
        }

        let audioAsset = record["audio"] as? CKAsset
        let audioURL = audioAsset?.fileURL

        // Parse vocabulary (stored as JSON string)
        let vocabulary: [VocabularyItem]
        if let vocabJSON = record["vocabulary"] as? String,
           let vocabData = vocabJSON.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([VocabularyItem].self, from: vocabData) {
            vocabulary = decoded
        } else {
            vocabulary = []
        }

        // Parse quiz (stored as JSON string)
        let quiz: Quiz
        if let quizJSON = record["quiz"] as? String,
           let quizData = quizJSON.data(using: .utf8),
           let decoded = try? JSONDecoder().decode(Quiz.self, from: quizData) {
            quiz = decoded
        } else {
            quiz = Quiz(questions: [])
        }

        let duaContent = DuaContent(
            arabicText: arabicText,
            transliteration: transliteration,
            translation: translation,
            context: context,
            explanation: explanation,
            audioURL: audioURL,
            vocabulary: vocabulary,
            quiz: quiz
        )

        return Lesson(
            id: id,
            moduleId: moduleId,
            orderIndex: orderIndex,
            title: title,
            duaOrVerse: duaContent,
            isPremium: record["isPremium"] as? Bool ?? false
        )
    }

    // MARK: - User Progress Sync

    func syncUserProgress(
        completedLessons: Set<UUID>,
        hasanat: Int,
        streak: Streak
    ) async {
        guard cloudKitAvailable, let container = container, let privateDatabase = privateDatabase else {
            return
        }

        do {
            let recordID = try await container.userRecordID()
            let record = try await privateDatabase.record(for: recordID)

            // Encode completed lessons as array of strings
            let lessonIDs = completedLessons.map { $0.uuidString }
            record["completedLessons"] = lessonIDs as CKRecordValue

            record["hasanat"] = hasanat as CKRecordValue
            record["lessonStreak"] = streak.lessonStreak as CKRecordValue
            record["wisdomStreak"] = streak.wisdomStreak as CKRecordValue
            record["longestLessonStreak"] = streak.longestLessonStreak as CKRecordValue
            record["longestWisdomStreak"] = streak.longestWisdomStreak as CKRecordValue

            if let lastLessonDate = streak.lastLessonDate {
                record["lastLessonDate"] = lastLessonDate as CKRecordValue
            }

            if let lastWisdomDate = streak.lastWisdomDate {
                record["lastWisdomDate"] = lastWisdomDate as CKRecordValue
            }

            try await privateDatabase.save(record)
        } catch {
            print("Error syncing user progress: \(error)")
        }
    }

    // MARK: - Analytics

    func trackEvent(name: String, properties: [String: Any]) async {
        guard cloudKitAvailable, let publicDatabase = publicDatabase else {
            return
        }

        let record = CKRecord(recordType: "AnalyticsEvent")
        record["eventName"] = name as CKRecordValue
        record["timestamp"] = Date() as CKRecordValue

        // Store properties as JSON string
        if let jsonData = try? JSONSerialization.data(withJSONObject: properties),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            record["properties"] = jsonString as CKRecordValue
        }

        do {
            try await publicDatabase.save(record)
        } catch {
            print("Error tracking event: \(error)")
        }
    }
}

// MARK: - Wisdom Repository

class WisdomRepository: ObservableObject {
    static let shared = WisdomRepository()

    @Published var allWisdom: [WisdomCard] = []
    @Published var isLoading = false

    private let cloudKit = CloudKitManager.shared
    private let cacheKey = "cachedWisdomCards"

    private init() {
        loadFromCache()
    }

    func fetchWisdom(forDay day: Int) async -> WisdomCard? {
        #if DEBUG
        // In DEBUG mode, use mock data
        return MockData.wisdomCard(forDay: day)
        #else
        // Try to fetch from CloudKit
        if let wisdom = await cloudKit.fetchWisdom(forDay: day) {
            return wisdom
        }

        // Fallback to cached data
        return allWisdom.first { $0.dayInCycle == day }
        #endif
    }

    func fetchAllWisdom() async {
        isLoading = true
        defer { isLoading = false }

        allWisdom = await cloudKit.fetchAllWisdomCards()
        saveToCache()
    }

    private func loadFromCache() {
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let decoded = try? JSONDecoder().decode([WisdomCard].self, from: data) {
            allWisdom = decoded
        }
    }

    private func saveToCache() {
        if let encoded = try? JSONEncoder().encode(allWisdom) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        }
    }
}

// MARK: - Analytics Manager

class AnalyticsManager {
    static let shared = AnalyticsManager()

    private let cloudKit = CloudKitManager.shared

    private init() {}

    func track(event: String, properties: [String: Any] = [:]) async {
        await cloudKit.trackEvent(name: event, properties: properties)

        // Also log locally for debugging
        #if DEBUG
        print("📊 Analytics: \(event) - \(properties)")
        #endif
    }

    func trackScreenView(_ screenName: String) async {
        await track(event: "screen_view", properties: ["screen": screenName])
    }

    func trackLessonComplete(lessonId: UUID, hasanatEarned: Int, timeSpent: TimeInterval) async {
        await track(event: "lesson_completed", properties: [
            "lesson_id": lessonId.uuidString,
            "hasanat_earned": hasanatEarned,
            "time_spent_seconds": Int(timeSpent)
        ])
    }

    func trackStreakMilestone(type: String, days: Int) async {
        await track(event: "streak_milestone", properties: [
            "type": type,
            "days": days
        ])
    }

    func trackPremiumConversion(source: String) async {
        await track(event: "premium_conversion", properties: [
            "source": source
        ])
    }
}
