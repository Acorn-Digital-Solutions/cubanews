# Environment Configuration for cubanews-ios

This document explains how the environment configuration is set up for the iOS app.

## Overview

The cubanews-ios app now uses environment-specific configuration files to manage different API endpoints for development and production environments.

## Configuration Files

### 1. Debug.xcconfig
Located at: `cubanews-ios/Debug.xcconfig`

Contains configuration for the **Debug** build:
- `CUBANEWS_API = http://localhost:3000/api`

This points to your local development server.

### 2. Release.xcconfig
Located at: `cubanews-ios/Release.xcconfig`

Contains configuration for the **Release** build:
- `CUBANEWS_API = https://www.cubanews.icu/api`

This points to the production server.

## How It Works

1. **Build Configuration Files (.xcconfig)**: These files define build-time variables that are injected into the app's Info.plist during the build process.

2. **Config.swift**: This Swift file provides a type-safe way to access the environment variables at runtime:
   ```swift
   enum Config {
       static var CUBANEWS_API: String {
           guard let apiURL = Bundle.main.object(forInfoDictionaryKey: "CUBANEWS_API") as? String else {
               fatalError("CUBANEWS_API not found in Info.plist")
           }
           return apiURL
       }
   }
   ```

3. **CubanewsViewModel**: The view model now uses `Config.CUBANEWS_API` to construct API URLs:
   ```swift
   let urlString = "\(Config.CUBANEWS_API)/feed?page=\(currentPage)&pageSize=\(pageSize)"
   ```

## Usage

### Development (Debug)
When you build and run the app in Debug mode (default when running from Xcode):
- The app will use `http://localhost:3000/api`
- Make sure your local cubanews-feed server is running on port 3000

### Production (Release)
When you build and archive the app for production:
- The app will use `https://www.cubanews.icu/api`
- This is the live production API

## Switching Between Environments

In Xcode:
1. Select your scheme (usually "cubanews-ios")
2. Go to **Product > Scheme > Edit Scheme...**
3. Select **Run** from the left sidebar
4. Under **Build Configuration**, choose:
   - **Debug** for local development
   - **Release** for production builds

## Adding New Environment Variables

To add a new environment variable:

1. Add the variable to both `Debug.xcconfig` and `Release.xcconfig`:
   ```
   MY_NEW_VARIABLE = value
   ```

2. Add it to the Info.plist keys in `project.pbxproj`:
   ```
   INFOPLIST_KEY_MY_NEW_VARIABLE = "$(MY_NEW_VARIABLE)";
   ```

3. Add a property in `Config.swift`:
   ```swift
   static var MY_NEW_VARIABLE: String {
       guard let value = Bundle.main.object(forInfoDictionaryKey: "MY_NEW_VARIABLE") as? String else {
           fatalError("MY_NEW_VARIABLE not found in Info.plist")
       }
       return value
   }
   ```

4. Use it in your code:
   ```swift
   let myValue = Config.MY_NEW_VARIABLE
   ```
