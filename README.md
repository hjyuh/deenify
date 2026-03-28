# Deenify - Duolingo for Islamic Learning

A privacy-first, ad-free iOS app built with SwiftUI to help Muslims build lasting spiritual habits through gamified daily lessons and wisdom.

## 🚀 Quick Start

### ⚠️ Important: Xcode Project Setup Required

The Swift code is ready, but you need to create the Xcode project file (.xcodeproj) since these can't be generated programmatically.

**📖 Follow the step-by-step guide: [XCODE_SETUP_GUIDE.md](./XCODE_SETUP_GUIDE.md)**

It takes **~5 minutes** and walks you through:
1. Creating a new Xcode project
2. Adding the Swift files
3. Configuring CloudKit
4. Running the app

### Project Structure

```
deenify/
├── XCODE_SETUP_GUIDE.md      ← START HERE! Setup instructions
├── RAPID_MVP_ROADMAP.md       ← 6-8 week shipping timeline
├── Deenify/                   ← All Swift source code
│   ├── App/                   ← App entry point
│   ├── Core/                  ← Business logic & data
│   ├── Features/              ← UI features (Wisdom, Lessons, Streaks)
│   ├── Shared/                ← Reusable components
│   ├── Info.plist             ← App configuration
│   └── README.md              ← Code documentation
└── outline                    ← Strategic product plan
```

## 📱 What's Built

### ✅ Fully Implemented Features

- **Daily Wisdom System** - 7-day rotation of Islamic content (Duas, Verses, Hadiths, Stories)
- **Streak Tracking** - Dual streaks for lessons + wisdom with celebration animations
- **Smart Notifications** - Context-aware push notifications (7 AM & 9 PM)
- **CloudKit Backend** - Zero server cost, offline-first architecture
- **Gamification** - Hasanat points, levels, badges, progress tracking
- **Social Sharing** - Beautiful shareable wisdom cards for Instagram/WhatsApp
- **Design System** - Complete UI component library with modern Islamic aesthetic

### 🚧 To Be Completed

- Lesson detail view with interactive quiz
- Premium paywall (StoreKit 2)
- Sign in with Apple
- Onboarding flow
- Sample content (50 wisdom cards, 10 lessons)

## 🛠 Tech Stack

- **SwiftUI** - Modern declarative UI
- **Swift Concurrency** - async/await
- **CloudKit** - Backend & sync
- **Combine** - Reactive state
- **UserNotifications** - Push notifications
- **Clean Architecture + MVVM**

## 💰 Cost to Run

**$120/year** total (until 10K+ users):
- CloudKit: **$0** (free tier)
- App Store: **$99/year**
- Domain: **~$20/year**

No Firebase, no AWS, no monthly fees!

## 📊 Success Metrics

**Target (First 30 Days)**:
- 1,000 downloads
- 60% D1 retention
- 40% D7 retention
- 20% premium conversion

## 🎯 Strategic Positioning

Built to fill the gap left by the Muslim Pro data scandal:
- **100% ad-free** - No tracking SDKs
- **Privacy-first** - No location data
- **Trust-based freemium** - Core features free forever
- **Gamified learning** - Duolingo's mechanics + Islamic content
- **Daily touchpoints** - Wisdom (30 sec) + Lessons (5 min)

## 📚 Documentation

- **[XCODE_SETUP_GUIDE.md](./XCODE_SETUP_GUIDE.md)** - How to create the Xcode project (start here!)
- **[RAPID_MVP_ROADMAP.md](./RAPID_MVP_ROADMAP.md)** - 6-8 week development plan
- **[Deenify/README.md](./Deenify/README.md)** - Code architecture & API docs
- **[outline](./outline)** - Full strategic product plan (market analysis, monetization, go-to-market)

## 🚢 Shipping Timeline

- **Week 1-2**: Foundation ✅ (DONE)
- **Week 3-4**: Daily Wisdom ✅ (DONE)
- **Week 5-6**: Core lessons (in progress)
- **Week 7**: Polish & gamification
- **Week 8**: TestFlight launch

**Target Launch**: Ramadan (peak user acquisition window)

## 🎨 Design Philosophy

- **Calm & Respectful** - Not gamifying worship, scaffolding habits
- **Accessible** - VoiceOver, Dynamic Type, offline-first
- **Beautiful** - Modern Islamic aesthetic (Teal, Gold, Cream palette)
- **Shareable** - Every wisdom card is Instagram-ready

## 🔐 Privacy Principles

1. **No ad SDKs** - Zero third-party tracking
2. **No location data** - Never requested or stored
3. **Data minimization** - Only collect what's needed for features
4. **Transparent policy** - Plain English, user-friendly
5. **CloudKit encryption** - Data encrypted at rest & in transit

## 🤝 Contributing

This is a solo MVP for now, but the code is open for:
- Bug reports
- Feature suggestions
- Code improvements
- Content contributions (Duas, Hadiths, wisdom)

## 📄 License

MIT License - See LICENSE file for details

## 🙏 Acknowledgments

Built with ❤️ for the global Muslim community.

Inspired by:
- Duolingo's learning methodology
- The need for trust after Muslim Pro scandal
- Apps like Tarteel AI (privacy-first success)

---

## Next Steps

1. **Read [XCODE_SETUP_GUIDE.md](./XCODE_SETUP_GUIDE.md)** to create the Xcode project
2. **Add sample content** to CloudKit (wisdom cards & lessons)
3. **Test on device** (notifications don't work in simulator)
4. **Iterate and ship!**

**Questions?** Check the guides or open an issue.

---

**Ready to build the Duolingo for Deen? Let's ship this! 🚀**
