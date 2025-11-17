# 📱 Xcode Project Setup Guide

Since Xcode project files (.xcodeproj) can't be created programmatically without Xcode, follow these steps to create your project:

## Method 1: Quick Setup (Recommended - 5 minutes)

### Step 1: Create New Xcode Project

1. **Open Xcode**
2. **File > New > Project** (or press `⇧⌘N`)
3. Select **iOS > App**
4. Click **Next**

### Step 2: Configure Project Settings

Fill in these details:
- **Product Name**: `Deenify`
- **Team**: Select your Apple Developer account
- **Organization Identifier**: `com.yourname` (use your own)
- **Bundle Identifier**: Will auto-generate as `com.yourname.Deenify`
- **Interface**: **SwiftUI**
- **Language**: **Swift**
- **Storage**: Leave as default
- **Include Tests**: ✅ Check it

Click **Next**, then save it in: `/home/user/deenify/`

### Step 3: Replace Default Files

Xcode created some default files. We'll replace them with our code:

1. **In Xcode's Project Navigator**, you'll see:
   ```
   Deenify/
   ├── DeenifyApp.swift  (delete this)
   ├── ContentView.swift (delete this)
   └── Assets.xcassets
   ```

2. **Delete the default files**:
   - Right-click `DeenifyApp.swift` > Delete > Move to Trash
   - Right-click `ContentView.swift` > Delete > Move to Trash

### Step 4: Add Our Code Files

1. **In Finder**, navigate to `/home/user/deenify/Deenify/`

2. **Drag these folders** into Xcode's Project Navigator:
   - `App/` folder
   - `Core/` folder
   - `Features/` folder
   - `Shared/` folder

3. When the dialog appears:
   - ✅ Check **"Copy items if needed"**
   - ✅ Select **"Create groups"** (NOT folders)
   - ✅ Add to target: **Deenify**

Your project structure should now look like:
```
Deenify/
├── App/
│   └── DeenifyApp.swift
├── Core/
│   ├── Domain/
│   └── Data/
├── Features/
│   ├── DailyWisdom/
│   ├── Streaks/
│   └── MainTabView.swift
├── Shared/
│   └── Utils/
└── Assets.xcassets
```

### Step 5: Add Capabilities

1. Select **Deenify** project in navigator (blue icon at top)
2. Select **Deenify** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **"iCloud"**
6. Under iCloud, check **"CloudKit"**
7. Click the **+** button under "Containers"
8. Add container: `iCloud.com.yourname.Deenify` (or create new)

### Step 6: Fix Any Import Issues

Some files might show errors. Add these frameworks:

1. Select `NotificationManager.swift`
2. If there are errors, make sure these imports are at the top:
   ```swift
   import Foundation
   import UserNotifications
   ```

3. Do the same for other files showing errors

### Step 7: Build & Run

1. Select **iPhone 15 Pro** (or any simulator) from device menu
2. Press **⌘R** or click the Play button
3. First build will take 1-2 minutes

If you get errors, check the **Common Issues** section below.

---

## Method 2: Create from Scratch (Alternative)

If Method 1 doesn't work, create the project manually:

### Create Minimal Project Structure

```bash
cd /home/user/deenify
mkdir -p DeenifyApp/DeenifyApp

# Create minimal project
# Note: This creates a new folder to avoid conflicts
```

Then in Xcode:
1. File > New > Project
2. Save in new `DeenifyApp/` folder
3. Copy files from `Deenify/` to `DeenifyApp/DeenifyApp/`
4. Add files to Xcode project

---

## Common Issues & Fixes

### Issue 1: "Cannot find type 'AppColor' in scope"

**Fix**: Make sure `DesignSystem.swift` is added to the project target
- Right-click file > Show File Inspector
- Check that "Target Membership" includes "Deenify"

### Issue 2: "Missing required module 'CloudKit'"

**Fix**: Add CloudKit capability (see Step 5 above)

### Issue 3: Font errors with Arabic text

**Fix**: Download and add Amiri Quran font:
1. Download from [Google Fonts](https://fonts.google.com/specimen/Amiri+Quran)
2. Drag `.ttf` files into Xcode project
3. Add to `Info.plist`:
   - Right-click Info.plist > Open As > Source Code
   - Add before closing `</dict>`:
   ```xml
   <key>UIAppFonts</key>
   <array>
       <string>AmiriQuran-Regular.ttf</string>
   </array>
   ```

### Issue 4: SwiftUI Preview not working

**Fix**:
- Make sure all files compile first (⌘B)
- Resume preview with `⌥⌘P`
- Or add preview provider at bottom of file:
  ```swift
  #Preview {
      DailyWisdomView()
  }
  ```

### Issue 5: Simulator shows blank white screen

**Fix**: Check console for errors
- View > Debug Area > Activate Console (⇧⌘C)
- Look for specific error messages
- Most common: Missing environment objects

---

## Verification Checklist

Once set up, verify everything works:

- [ ] Project builds without errors (⌘B)
- [ ] App launches in simulator
- [ ] No red errors in console
- [ ] All Swift files show in Project Navigator
- [ ] CloudKit capability is enabled
- [ ] Bundle identifier is set correctly

---

## Next Steps After Setup

1. **Add Sample Data**:
   - Create wisdom cards in CloudKit dashboard
   - Or use local mock data for testing

2. **Configure Notifications**:
   - Test on physical device (notifications don't work in simulator)

3. **Add App Icon**:
   - Create 1024x1024 icon
   - Add to Assets.xcassets

4. **Start Developing**:
   - Check `RAPID_MVP_ROADMAP.md` for feature roadmap
   - See `Deenify/README.md` for architecture guide

---

## Still Having Issues?

### Option A: Create Minimal Test Project

I can help you create a minimal version to test the setup:

1. Create new project with just one file
2. Verify it builds
3. Then add remaining files gradually

### Option B: Use Swift Playground

For quick testing without full project:
1. Xcode > File > New > Playground
2. Test individual components
3. Copy to main project once working

---

## Quick Reference: File Organization

```
Xcode Project Structure:
└── Deenify (blue icon - this is the project)
    └── Deenify (yellow folder - this is the target)
        ├── App/
        │   └── DeenifyApp.swift          ← Entry point
        ├── Core/
        │   ├── Domain/
        │   │   └── Models.swift          ← All data models
        │   └── Data/
        │       └── CloudKitManager.swift ← Backend
        ├── Features/
        │   ├── DailyWisdom/
        │   │   └── DailyWisdomView.swift ← Main feature
        │   ├── Streaks/
        │   │   └── StreakManager.swift   ← Streak logic
        │   └── MainTabView.swift         ← Navigation
        ├── Shared/
        │   └── Utils/
        │       ├── DesignSystem.swift    ← UI components
        │       └── NotificationManager.swift
        └── Assets.xcassets               ← Images & colors
```

---

**Need Help?** Check the code comments in each Swift file for detailed documentation!

🚀 Once set up, run the app and you should see the splash screen followed by onboarding!
