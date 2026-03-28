//
//  DeenifyApp.swift
//  Deenify
//
//  A Duolingo-style Islamic learning app
//  Privacy-first, ad-free, trust-based
//

import SwiftUI
import UserNotifications
import Combine

@main
struct DeenifyApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var streakManager = StreakManager()
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var userProgress = UserProgress.shared

    init() {
        setupAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(streakManager)
                .environmentObject(notificationManager)
                .environmentObject(userProgress)
                .onAppear {
                    setupNotifications()
                    checkStreaks()
                }
                .task {
                    await loadInitialData()
                }
        }
    }

    // MARK: - Setup Methods

    private func setupAppearance() {
        // Custom navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()

        // Use direct UIColor hex values to avoid conversion issues
        appearance.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 247.0/255.0, alpha: 1.0) // Cream
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
            .foregroundColor: UIColor(red: 31.0/255.0, green: 41.0/255.0, blue: 55.0/255.0, alpha: 1.0) // Charcoal
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    private func setupNotifications() {
        Task {
            await notificationManager.requestAuthorization()
            await notificationManager.scheduleDailyNotifications()
        }
    }

    private func checkStreaks() {
        Task {
            await streakManager.checkAndUpdateStreaks()
        }
    }

    private func loadInitialData() async {
        // Load user data, sync with CloudKit
        await appState.initialize()
    }
}

// MARK: - App State Manager

@MainActor
class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding = false
    @Published var currentUser: User?
    @Published var isLoading = false

    private let cloudKitManager = CloudKitManager.shared
    private let userDefaults = UserDefaults.standard

    init() {
        checkOnboardingStatus()
    }

    func initialize() async {
        isLoading = true
        defer { isLoading = false }

        // Check authentication status
        isAuthenticated = await cloudKitManager.checkAccountStatus()

        if isAuthenticated {
            // Load user profile
            currentUser = await cloudKitManager.fetchUserProfile()
        }
    }

    private func checkOnboardingStatus() {
        hasCompletedOnboarding = userDefaults.bool(forKey: "hasCompletedOnboarding")
    }

    func completeOnboarding() {
        userDefaults.set(true, forKey: "hasCompletedOnboarding")
        hasCompletedOnboarding = true
    }
}

// MARK: - Content View

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.isLoading {
                SplashView()
            } else if !appState.hasCompletedOnboarding {
                OnboardingView()
            } else if !appState.isAuthenticated {
                AuthenticationView()
            } else {
                MainTabView()
            }
        }
    }
}
