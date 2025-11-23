# Sign in with Apple Configuration Guide

## Overview
This document outlines the required configuration steps to enable Sign in with Apple in the Cubanews iOS app.

## Prerequisites
- Active Apple Developer Program membership
- Xcode installed on your development machine
- Access to the Apple Developer Portal

## Configuration Steps

### 1. Apple Developer Portal Setup

#### A. Create or Update App ID
1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select **Identifiers** from the sidebar
4. Either create a new App ID or edit your existing one:
   - **Description**: Cubanews iOS App
   - **Bundle ID**: `[YOUR_BUNDLE_ID]` (e.g., `com.acorndigital.cubanews`)
   - **Team ID**: `[YOUR_TEAM_ID]`

#### B. Enable Sign in with Apple Capability
1. In the App ID capabilities list, enable **Sign in with Apple**
2. Click **Save**

### 2. Xcode Project Configuration

#### A. Add Sign in with Apple Capability
1. Open the Xcode project: `cubanews-ios.xcodeproj`
2. Select the **cubanews-ios** target
3. Go to the **Signing & Capabilities** tab
4. Click the **+ Capability** button
5. Add **Sign in with Apple**
6. Ensure your Team is selected in the Signing section

#### B. Configure Bundle Identifier
1. In the **General** tab of your target settings
2. Set the **Bundle Identifier** to: `[YOUR_BUNDLE_ID]`
   - Example: `com.acorndigital.cubanews`
   - This must match the Bundle ID in your App ID

#### C. Verify Provisioning Profile
1. Ensure you have a valid provisioning profile that includes:
   - Sign in with Apple entitlement
   - Your Bundle Identifier
   - Your Team ID

### 3. Entitlements File (Auto-generated)

When you add the Sign in with Apple capability, Xcode automatically creates or updates:
- **File**: `cubanews-ios.entitlements`
- **Location**: In the project directory

The file should contain:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>
</dict>
</plist>
```

### 4. Required Placeholders

Replace the following placeholders throughout the project:

| Placeholder | Example Value | Where to Set |
|------------|---------------|--------------|
| `[YOUR_TEAM_ID]` | `ABC123XYZ4` | Apple Developer Portal |
| `[YOUR_BUNDLE_ID]` | `com.acorndigital.cubanews` | Xcode Project Settings |

### 5. Testing Configuration

#### Development Testing
1. Ensure your device/simulator is signed into an Apple ID
2. For simulator: Go to **Settings** → **Sign in to your iPhone**
3. For device: Ensure you're signed into iCloud

#### Production Testing
1. Create a TestFlight build
2. Invite beta testers
3. Test the full sign-in flow with real Apple IDs

### 6. Privacy Configuration

Add the following to your **Info.plist** if needed:
```xml
<key>NSPrivacyAccessedAPITypes</key>
<array>
    <!-- Add any privacy-related configurations here -->
</array>
```

### 7. Backend Configuration (Optional)

If you need to verify the identity token on a backend server:

1. **Apple's Public Keys**: Use Apple's public keys to verify the JWT token
   - URL: `https://appleid.apple.com/auth/keys`

2. **Token Verification**: Verify the `identityToken` received from Sign in with Apple
   - Decode the JWT
   - Verify the signature
   - Check the issuer, audience, and expiration

3. **User Identifier**: The `user` field is a unique, stable identifier for the user
   - Store this in your backend database
   - Use it to associate app data with the user

### 8. Troubleshooting

#### Common Issues

**Issue**: "Sign in with Apple" button doesn't work
- **Solution**: Ensure capability is added in Xcode and App ID is configured in Developer Portal

**Issue**: "Invalid client" error
- **Solution**: Verify Bundle ID matches between Xcode and App ID

**Issue**: User email is nil
- **Solution**: Email is only provided on first sign-in; cache it in your app

**Issue**: Simulator shows "Sign in Failed"
- **Solution**: Ensure simulator is signed into an Apple ID in Settings

### 9. Data Privacy

Sign in with Apple provides enhanced privacy:
- Users can hide their email (Apple provides a relay email)
- No tracking or profiling
- Meets GDPR and privacy requirements

### 10. User Experience Notes

- Email and name are only provided on the **first** sign-in
- Store this information in SwiftData immediately
- On subsequent sign-ins, only the user ID is reliably provided
- Always handle the case where email/name might be nil

## Implementation Status

✅ User model created with SwiftData
✅ AuthenticationManager implemented
✅ LoginView updated with Sign in with Apple button
✅ ProfileView displays user information
✅ Logout and account deletion functionality implemented
✅ Persistent authentication state on app launch

## Required Actions

Before deploying to production:
1. [ ] Configure App ID in Apple Developer Portal
2. [ ] Add Sign in with Apple capability in Xcode
3. [ ] Set correct Bundle Identifier
4. [ ] Test on physical device
5. [ ] Test on TestFlight
6. [ ] Verify data persistence across app restarts
7. [ ] Test logout and delete account flows
