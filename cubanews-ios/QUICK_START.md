# Quick Start Guide - Sign in with Apple

This guide provides a quick overview for developers who need to configure and test Sign in with Apple in the Cubanews iOS app.

## ⚡ Quick Setup (5 minutes)

### Step 1: Xcode Configuration
1. Open `cubanews-ios.xcodeproj` in Xcode
2. Select the **cubanews-ios** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability** → Add **Sign in with Apple**
5. Ensure your development team is selected

### Step 2: Test on Simulator/Device
1. Make sure your simulator/device is signed into an Apple ID:
   - Settings → Sign in to your iPhone
2. Build and run the app (Cmd+R)
3. Tap "Sign in with Apple" button
4. Follow the authentication flow

### Step 3: Verify Implementation
1. After signing in, check that:
   - App navigates to the main feed
   - Your name appears in the Profile tab
   - App reopens to the feed (not login screen)
2. Test logout:
   - Go to Profile tab
   - Tap "Cerrar Sesión"
   - Verify you're back at login screen

## 🎯 Key Implementation Points

### User Model (`User.swift`)
```swift
@Model
final class User {
    @Attribute(.unique) var id: String  // Apple user ID
    var email: String?                   // May be relay email
    var fullName: String?
    var givenName: String?
    var familyName: String?
    // ... tokens and timestamps
}
```

### Authentication Manager (`AuthenticationManager.swift`)
```swift
@MainActor
class AuthenticationManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool
    
    func handleSignInWithApple(...)  // Handles sign in
    func signOut()                   // Clears user data
    func deleteAccount()             // Removes user
}
```

### Login Flow
```
LoginView → SignInWithAppleButton → 
handleSignInWithApple → AuthenticationManager → 
Save to SwiftData → isAuthenticated = true → 
ContentView
```

## 🔧 Configuration Checklist

### Development
- [x] Code implemented
- [ ] Sign in with Apple capability added in Xcode
- [ ] Development team selected
- [ ] Device/simulator has Apple ID
- [ ] Test sign in flow
- [ ] Test persistence (restart app)
- [ ] Test logout

### Production
- [ ] App ID created in Developer Portal
- [ ] Bundle ID set: `[YOUR_BUNDLE_ID]`
- [ ] Team ID configured: `[YOUR_TEAM_ID]`
- [ ] Sign in with Apple enabled in App ID
- [ ] Provisioning profile updated
- [ ] TestFlight testing completed
- [ ] Production testing completed

## 📱 User Experience Flow

### First Sign In
```
1. User sees LoginView
2. Taps "Sign in with Apple" (black button)
3. Face ID/Touch ID prompt
4. Email sharing prompt (can hide)
5. Success → Saves to SwiftData
6. Navigates to ContentView
```

### Returning User
```
1. App launches
2. AuthenticationManager loads User from SwiftData
3. Auto-authenticated
4. Shows ContentView immediately
```

### Sign Out
```
1. ProfileView → "Cerrar Sesión" button
2. Deletes User from SwiftData
3. Returns to LoginView
```

## 🐛 Common Issues & Fixes

| Issue | Solution |
|-------|----------|
| Button doesn't work | Add capability in Xcode |
| "Invalid client" error | Check Bundle ID matches |
| Email is nil | Normal on subsequent sign-ins |
| Crash on launch | Check ModelContainer initialization |
| Not persisting | Verify SwiftData setup |

## 🔍 Debugging Tips

### Check SwiftData
```swift
// In AuthenticationManager.swift
print("Current user: \(currentUser?.displayName ?? "none")")
print("Authenticated: \(isAuthenticated)")
```

### View Logs
Look for these log messages:
- ✅ `Loaded existing user: [name]`
- ✅ `Created new user: [name]`
- ✅ `User signed out`
- ❌ `Sign in with Apple failed: [error]`

### Test Data Persistence
1. Sign in successfully
2. Force quit app (swipe up)
3. Relaunch app
4. Should NOT show login screen

## 📚 Key Files

| File | Purpose |
|------|---------|
| `User.swift` | SwiftData model for user data |
| `AuthenticationManager.swift` | Auth logic & state |
| `LoginView.swift` | Sign in UI |
| `cubanews_iosApp.swift` | App initialization |
| `ProfileView.swift` | User info display |

## 🔐 Security Notes

- ✅ All data stored locally (SwiftData)
- ✅ Identity tokens encrypted
- ✅ Email can be hidden by user
- ✅ No backend calls (yet)
- ✅ Privacy-first design

## 📖 Additional Resources

- **Full Configuration**: See `APPLE_SIGNIN_CONFIGURATION.md`
- **Implementation Details**: See `IMPLEMENTATION_SUMMARY.md`
- **Apple Docs**: [developer.apple.com/sign-in-with-apple](https://developer.apple.com/sign-in-with-apple/)

## 🆘 Need Help?

1. Check `APPLE_SIGNIN_CONFIGURATION.md` for setup
2. Check `IMPLEMENTATION_SUMMARY.md` for details
3. Review Apple's official documentation
4. Check Xcode console for error logs

---

**Quick Reference**
- ✅ Production-ready code
- ✅ SwiftData persistence
- ✅ iOS 17+ required
- ✅ No backend needed (yet)
- 🔧 Needs Apple configuration
