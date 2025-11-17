# Deenify iOS App

A Duolingo-style Islamic learning app built with SwiftUI. Privacy-first, ad-free, and designed to build lasting spiritual habits.

## 🚀 Quick Start

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Apple Developer Account (for CloudKit)

### Setup Steps

1. **Open in Xcode**
   ```bash
   cd Deenify
   open Deenify.xcodeproj
   ```

2. **Configure CloudKit**
   - Select your project in Xcode
   - Go to Signing & Capabilities
   - Add "iCloud" capability
   - Enable "CloudKit"
   - Create container: `iCloud.com.deenify.app` (or use your own)

3. **Update Bundle Identifier**
   - Change to your own: `com.yourname.deenify`

4. **Add Arabic Font (Optional but Recommended)**
   - Download [Amiri Quran font](https://fonts.google.com/specimen/Amiri+Quran)
   - Add `AmiriQuran-Regular.ttf` and `AmiriQuran-Bold.ttf` to project
   - Add to `Info.plist`:
   ```xml
   <key>UIAppFonts</key>
   <array>
       <string>AmiriQuran-Regular.ttf</string>
       <string>AmiriQuran-Bold.ttf</string>
   </array>
   ```

5. **Run on Simulator or Device**
   - Select target device
   - Press `Cmd + R`

## 📁 Project Structure

```
Deenify/
├── App/
│   └── DeenifyApp.swift          # App entry point
│
├── Core/
│   ├── Domain/
│   │   └── Models.swift          # Core data models
│   └── Data/
│       └── CloudKitManager.swift # Backend & sync
│
├── Features/
│   ├── DailyWisdom/
│   │   └── DailyWisdomView.swift # Daily wisdom cards
│   ├── Streaks/
│   │   └── StreakManager.swift   # Streak tracking
│   └── MainTabView.swift         # Main navigation
│
└── Shared/
    ├── Components/               # Reusable UI
    ├── Extensions/
    └── Utils/
        ├── DesignSystem.swift    # Colors, fonts, components
        └── NotificationManager.swift # Push notifications
```

## 🎨 Architecture

### Clean Architecture + MVVM

- **Domain Layer**: Business logic and entities (`Models.swift`)
- **Data Layer**: Repositories and CloudKit integration
- **Presentation Layer**: ViewModels and SwiftUI Views

### Key Patterns Used

1. **Singleton Managers**: `UserProgress`, `CloudKitManager`, `NotificationManager`
2. **Observable Objects**: For reactive state management
3. **Async/Await**: For all async operations
4. **Environment Objects**: Share state across views

## 🔑 Key Features

### 1. Daily Wisdom System ✨
- **7-day rotation cycle**: Name of Allah, Dua, Verse, Hadith, Story, Tip, Quote
- **Shareable cards**: Instagram-ready with branding
- **Separate streak**: Independent from lessons
- **Bookmarking**: 5 free, unlimited for premium

**Files**: `DailyWisdomView.swift`

### 2. Lesson System 📚
- **5-step flow**: Context → Audio → Vocabulary → Explanation → Quiz
- **Hasanat points**: Gamified learning rewards
- **Progress tracking**: Sync via CloudKit

**Files**: `MainTabView.swift`, `Models.swift`

### 3. Streak Tracking 🔥
- **Dual streaks**: Lessons + Wisdom
- **Critical warnings**: Don't lose your streak!
- **Celebrations**: Milestone animations

**Files**: `StreakManager.swift`

### 4. Smart Notifications 🔔
- **Dual daily**: 7 AM (lessons), 9 PM (wisdom)
- **Context-aware**: Different copy based on streak status
- **Recovery reminders**: Bring back lapsed users

**Files**: `NotificationManager.swift`

## 💾 Data & Backend

### CloudKit Setup

#### Record Types to Create in CloudKit Dashboard

1. **WisdomCard**
   - `id` (String)
   - `type` (String) - "Name of Allah", "Quick Dua", etc.
   - `dayInCycle` (Int64) - 1 to 7
   - `arabicText` (String)
   - `transliteration` (String)
   - `translation` (String)
   - `explanation` (String)
   - `category` (String) - "Patience", "Gratitude", etc.
   - `source` (String) - Citation
   - `isPremium` (Int64) - 0 or 1

2. **Lesson**
   - `id` (String)
   - `moduleId` (String)
   - `orderIndex` (Int64)
   - `title` (String)
   - `arabicText` (String)
   - `transliteration` (String)
   - `translation` (String)
   - `context` (String)
   - `explanation` (String)
   - `audio` (Asset) - MP3 file
   - `vocabulary` (String) - JSON array
   - `quiz` (String) - JSON object
   - `isPremium` (Int64)

3. **UserProfile** (Private Database)
   - `userID` (String)
   - `name` (String)
   - `email` (String)
   - `hasanat` (Int64)
   - `level` (Int64)
   - `premiumStatus` (String)
   - `completedLessons` (List<String>)
   - `lessonStreak` (Int64)
   - `wisdomStreak` (Int64)
   - `lastLessonDate` (Date/Time)
   - `lastWisdomDate` (Date/Time)

### Offline-First Strategy

- All content is cached locally using `UserDefaults` (for demo) or Core Data (production)
- Background sync via CloudKit when online
- App works 100% offline after initial data fetch

## 🎨 Design System

### Colors

```swift
AppColor.primary       // Teal #0D9488
AppColor.secondary     // Gold #D4AF37
AppColor.background    // Cream #FFFEF7
AppColor.gold          // Badges & premium
```

### Typography

```swift
AppFont.arabic(size: 32)  // For Arabic text
AppFont.title             // Headlines
AppFont.body              // Body text
```

### Components

- `PrimaryButton` - Main CTAs
- `SecondaryButton` - Secondary actions
- `LoadingView` - Loading states
- `EmptyStateView` - Empty content
- `ErrorView` - Error handling

## 📊 Analytics

Events tracked:
- `screen_view`: Page navigation
- `wisdom_shared`: Social sharing
- `lesson_completed`: Lesson completion
- `streak_milestone`: Streak achievements
- `premium_conversion`: Upgrade to premium

## 🔐 Privacy Features

- **No ad SDKs**: Zero third-party tracking
- **No location data**: Never requested or stored
- **Data anonymization**: Personal data separated from usage data
- **Clear privacy policy**: Plain English, user-friendly

## 🚢 Shipping Checklist

### Before TestFlight

- [ ] Add 50+ wisdom cards to CloudKit
- [ ] Add 10 lessons (Module 1: Morning/Evening Adhkar)
- [ ] Record audio files for lessons
- [ ] Create app icon (1024x1024)
- [ ] Add launch screen
- [ ] Test on physical device
- [ ] Enable push notifications
- [ ] Write privacy policy

### App Store Assets

- [ ] Screenshots (6.5" and 5.5")
- [ ] App preview video (optional)
- [ ] Description and keywords
- [ ] Support URL
- [ ] Marketing URL

## 🐛 Known Issues / TODOs

- [ ] Implement Sign in with Apple
- [ ] Add Core Data for better offline support
- [ ] Implement premium paywall (StoreKit 2)
- [ ] Add lesson detail view with quiz
- [ ] Implement spaced repetition algorithm
- [ ] Add journaling feature
- [ ] Create onboarding flow
- [ ] Add dark mode support
- [ ] Localization (Arabic, Urdu, French, etc.)

## 📈 Metrics to Track

### Week 1
- Downloads
- D1 Retention (60% target)
- Daily Wisdom views

### Week 2-4
- D7 Retention (40% target)
- Lesson completions
- Streak maintenance rate
- Social shares

### Month 1
- Premium conversion (20% target)
- Average session time
- User feedback/ratings

## 🤝 Contributing

This is a solo project for now, but contributions are welcome!

1. Fork the repo
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Inspired by Duolingo's learning methodology
- Built in response to the Muslim Pro data scandal
- Designed for the global Muslim community

---

**Built with ❤️ for the Ummah**

Ready to ship! 🚀 See `RAPID_MVP_ROADMAP.md` for development timeline.
