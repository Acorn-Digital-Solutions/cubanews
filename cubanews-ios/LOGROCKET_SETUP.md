# LogRocket Integration Setup Guide

## Overview

LogRocket has been integrated into the Cubanews iOS app alongside Firebase Analytics. LogRocket provides session replay and analytics for better understanding user behavior and debugging issues.

## Installation Steps

### 1. Add LogRocket Swift Package

1. Open your project in Xcode
2. Go to **File → Add Package Dependencies...**
3. Enter the LogRocket package URL:
   ```
   https://github.com/LogRocket/logrocket-ios
   ```
4. Select version: **1.0.0** or later
5. Click **Add Package**
6. Select the **LogRocket** library and add it to your target

### 2. Get Your LogRocket App ID

1. Sign up or log in at [LogRocket](https://app.logrocket.com)
2. Create a new application or select an existing one
3. Navigate to **Settings → Application**
4. Copy your App ID (format: `abc123/your-app-name`)

### 3. Configure Your App ID

Update the App ID in `cubanews_iosApp.swift`:

```swift
// Replace this line:
AnalyticsService.shared.initializeLogRocket(appId: "YOUR_LOGROCKET_APP_ID")

// With your actual App ID:
AnalyticsService.shared.initializeLogRocket(appId: "abc123/cubanews-ios")
```

**⚠️ Security Note**: Consider storing the LogRocket App ID in your environment configuration or using Xcode configuration files.

### 4. Optional: Store App ID in Environment Config

You can add the LogRocket App ID to your configuration files:

**Debug.xcconfig**:

```
LOGROCKET_APP_ID =
```

**Release.xcconfig**:

```
LOGROCKET_APP_ID = abc123/cubanews-ios
```

Then update `Config.swift` to include:

```swift
static var logRocketAppId: String {
    return Bundle.main.object(forInfoPlistKey: "LOGROCKET_APP_ID") as? String ?? ""
}
```

And in `Info.plist`:

```xml
<key>LOGROCKET_APP_ID</key>
<string>$(LOGROCKET_APP_ID)</string>
```

## Features Implemented

### Automatic Event Tracking

All analytics events are now automatically sent to both Firebase Analytics and LogRocket:

- Article views
- Article saves
- Article shares
- User login/signup
- Screen views
- Custom events

### User Identification

When a user logs in, they are automatically identified in LogRocket:

```swift
// This is already handled in AnalyticsService
AnalyticsService.shared.setUserId("user123")
```

### Custom User Traits

You can add additional user information:

```swift
AnalyticsService.shared.identifyUser("user123", traits: [
    "email": "user@example.com",
    "name": "John Doe",
    "plan": "premium"
])
```

### Custom Event Tracking

All existing event tracking continues to work and now sends to both platforms:

```swift
// Example: This now sends to both Firebase and LogRocket
AnalyticsService.shared.logArticleView(articleId: "123", source: "cibercuba")
```

## What LogRocket Provides

1. **Session Replay**: Watch exactly what users do in your app
2. **Error Tracking**: Automatic capture of crashes and errors
3. **Performance Monitoring**: Track app performance metrics
4. **User Analytics**: Understand user behavior patterns
5. **Issue Debugging**: Reproduce bugs by watching user sessions

## Privacy Considerations

LogRocket records user sessions. Ensure you:

1. Update your Privacy Policy to mention LogRocket
2. Consider adding user consent for session recording
3. Use LogRocket's privacy controls to sanitize sensitive data
4. Review Apple's App Store guidelines for analytics

## Debug vs Release Builds

- **Debug**: LogRocket is disabled, events only logged to console
- **Release**: LogRocket is fully enabled and records sessions

## Testing the Integration

1. Build the app in **Release** configuration
2. Log in as a user
3. Perform some actions (view articles, save, share)
4. Visit [LogRocket Dashboard](https://app.logrocket.com)
5. You should see sessions and events appearing

## Troubleshooting

### Events not appearing in LogRocket

- Verify the App ID is correct
- Check you're running a Release build
- Check the Xcode console for LogRocket initialization messages
- Ensure the package is properly linked to your target

### Build errors

- Make sure the Swift package is added correctly
- Clean build folder: **Product → Clean Build Folder**
- Restart Xcode

## Additional Configuration

### Disable specific screens from recording

```swift
#if !DEBUG
LogRocket.redactAllText()  // Redact all text
LogRocket.redactAllImages() // Redact all images
#endif
```

### Network request sanitization

LogRocket automatically captures network requests. Configure sanitization in the dashboard or programmatically.

## Support

- [LogRocket iOS Documentation](https://docs.logrocket.com/docs/ios-sdk)
- [LogRocket Dashboard](https://app.logrocket.com)
- [Support](https://logrocket.com/support)

## Next Steps

1. Add LogRocket Swift Package to your project
2. Get your App ID from LogRocket dashboard
3. Update the App ID in `cubanews_iosApp.swift`
4. Test in Release configuration
5. Review sessions in LogRocket dashboard
