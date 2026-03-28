# ⚡️ 5-Minute Quick Start

Get Deenify running in Xcode in 5 minutes.

## Why there's no .xcodeproj file

Xcode project files are binary/XML files that can only be properly created by Xcode itself. I've created all the Swift code for you - you just need to add it to a new Xcode project.

---

## 🎯 The 5-Minute Setup

### Step 1: Create Xcode Project (2 min)

1. Open **Xcode**
2. **File → New → Project** (or press `⇧⌘N`)
3. Select: **iOS** → **App**
4. Click **Next**

**Fill in**:
```
Product Name: Deenify
Team: (your Apple ID)
Organization Identifier: com.yourname
Bundle Identifier: com.yourname.Deenify
Interface: SwiftUI ← Important!
Language: Swift ← Important!
```

5. Click **Next**
6. Save location: `/home/user/deenify/`
7. Click **Create**

### Step 2: Delete Default Files (30 sec)

Xcode created some files we don't need:

In the **Project Navigator** (left sidebar):
- Right-click `DeenifyApp.swift` → **Delete** → Move to Trash
- Right-click `ContentView.swift` → **Delete** → Move to Trash

### Step 3: Add Our Code (1 min)

1. Open **Finder** → Navigate to `/home/user/deenify/Deenify/`

2. **Drag these 4 folders** into Xcode's Project Navigator:
   - `App/`
   - `Core/`
   - `Features/`
   - `Shared/`

3. In the popup dialog:
   - ✅ Check **"Copy items if needed"**
   - ✅ Select **"Create groups"**
   - ✅ Add to target: **Deenify**
   - Click **Finish**

### Step 4: Add CloudKit (1 min)

1. Click **Deenify** (blue icon at top of navigator)
2. Select **Deenify** target
3. **Signing & Capabilities** tab
4. Click **+ Capability** button
5. Double-click **"iCloud"**
6. Check **"CloudKit"**
7. Under Containers, click **+**
8. Enter: `iCloud.com.yourname.Deenify`

### Step 5: Run! (30 sec)

1. Select **iPhone 15 Pro** from device menu (top toolbar)
2. Press **⌘R** (or click Play button)
3. Wait for build...
4. **App launches!** 🎉

---

## 🎉 You Should See

When the app launches:
1. **Splash screen** with moon icon
2. **Onboarding** (first time only)
3. **Main tabs**:
   - Wisdom (sparkles icon)
   - Lessons (book icon)
   - Progress (chart icon)
   - Profile (person icon)

---

## ⚠️ If You Get Errors

### "Cannot find type 'AppColor'"

**Fix**: Build the project first
- Press **⌘B** (or Product → Build)
- Then try running again

### "Missing module 'CloudKit'"

**Fix**: Add CloudKit capability (see Step 4)

### "No such file or directory"

**Fix**: Make sure you saved the Xcode project in `/home/user/deenify/`
- The project should be saved **next to** the `Deenify/` folder, not inside it

### Build succeeds but app crashes

**Fix**: Check the console (View → Debug Area → Activate Console)
- Look for specific error message
- Most common: Missing environment objects (this is normal for first run)

---

## 📁 Correct File Structure

After setup, your folder should look like:

```
/home/user/deenify/
├── Deenify.xcodeproj/         ← Created by Xcode
├── Deenify/                    ← Our Swift code
│   ├── App/
│   ├── Core/
│   ├── Features/
│   ├── Shared/
│   └── Assets.xcassets/        ← Created by Xcode
├── XCODE_SETUP_GUIDE.md
└── README.md
```

**NOT**:
```
❌ /home/user/deenify/Deenify/Deenify.xcodeproj/  ← Wrong! Too nested
```

---

## 🚀 Next Steps After Setup

1. **Add sample data**
   - Go to CloudKit Dashboard
   - Add a few wisdom cards to test

2. **Test features**
   - Click on "Wisdom" tab
   - Check streak counter
   - Try bookmarking

3. **Read the docs**
   - `RAPID_MVP_ROADMAP.md` - What to build next
   - `Deenify/README.md` - Code architecture
   - `outline` - Full product strategy

---

## 🆘 Still Stuck?

### Option 1: Detailed Guide
Read the full setup guide: **[XCODE_SETUP_GUIDE.md](./XCODE_SETUP_GUIDE.md)**

### Option 2: Clean Slate
1. Delete the Xcode project
2. Start fresh following this guide again
3. Make sure to save in the right location

### Option 3: Check Requirements
- Xcode 15.0+
- macOS Sonoma (14.0+)
- Apple ID signed in

---

## ✅ Verification Checklist

After setup, confirm:

- [ ] Project builds without errors (⌘B)
- [ ] App launches in simulator
- [ ] You see 4 tabs at bottom
- [ ] "Wisdom" tab shows UI (might be empty without data)
- [ ] "Progress" tab shows streak cards
- [ ] No red errors in Xcode console

---

**Got it working? Awesome! Now check out `RAPID_MVP_ROADMAP.md` to see what to build next!** 🚀
