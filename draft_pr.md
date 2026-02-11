# PR Draft for #113

## Title
```
feat(expo): move anywhere-vessel to Expo
```

## Body

**Jira Ticket(s)**

Refs: [CTA-245](https://netfeasa.atlassian.net/browse/CTA-245), [CTA-358](https://netfeasa.atlassian.net/browse/CTA-358), [CTA-378](https://netfeasa.atlassian.net/browse/CTA-378), [CTA-379](https://netfeasa.atlassian.net/browse/CTA-379)

**Summary**

This PR completes the migration of the VCT Anywhere tablet application from React Native CLI to Expo managed workflow. This migration enables better cross-platform development, improved dependency management, and access to Expo's ecosystem of native modules.

**Key Achievements**

- ✅ **Complete Expo Migration**: Migrated entire app from `CTAnywhereApp/` to new `CTAnywhereExpo/` structure
- ✅ **Authentication Flow**: Implemented full AWS Cognito authentication with JWT token management
- ✅ **Offline-First Architecture**: Built robust offline queue system with SQLite persistence
- ✅ **Database Layer**: Created complete database abstraction with migrations and sync capabilities
- ✅ **Network Detection**: Implemented cross-platform network monitoring
- ✅ **Battery Indicator**: Added battery status monitoring for Android (expo-battery) and Electron (Web Battery API)
- ✅ **Security Fixes**: Resolved 8 high-severity npm vulnerabilities
- ✅ **Android UI Polish**: Removed system navigation bar overlay with immersive fullscreen mode

**Technical Implementation**

#### Core Infrastructure
- Expo SDK 54.0.32 with managed workflow
- TypeScript 5.7.3 with strict mode enabled
- expo-router for file-based navigation
- expo-sqlite for local database
- expo-battery for native battery monitoring

#### Authentication & Security
- AWS Cognito integration with secure token storage
- JWT refresh token mechanism
- Offline auth state persistence
- Fixed axios, tar, and electron-builder vulnerabilities

#### Offline Queue System
- SQLite-backed operation queue
- Automatic retry with exponential backoff
- Conflict resolution for sync operations
- Network-aware sync trigger

#### Platform-Specific Features
- **Android**: Native battery monitoring via expo-battery, immersive fullscreen mode
- **Electron**: Web Battery Status API integration, desktop-specific layouts
- **Cross-platform**: Unified battery service interface with platform detection


**Test Plan**
I will run the whole test matrix but after that PR is merge, it's chunky enough

**Build Commands**

```bash
# Electron
API_ENV=staging npm run electron:dev

# Android Release Build
cd CTAnywhereExpo
API_ENV=staging JAVA_HOME=/usr/lib/jvm/java-1.17.0-openjdk-amd64 npm run android

# Install on device
adb install -r android/app/build/outputs/apk/release/app-release.apk

# Type checking
npm run typecheck
```

**Breaking Changes**

None - this is a complete replacement of the old React Native CLI app structure.

**Migration Notes**

- Old app in `CTAnywhereApp/` remains for reference during transition period
- New Expo app is in `CTAnywhereExpo/` directory
- All future development should target Expo structure
- Build scripts updated to use Java 17 for Android builds

**Checklist**
- [x] PR title follows convention: `type(scope): description`
- [x] Jira ticket linked with `Refs:`, `Fixes:`, or `Closes:`
- [x] Jira ticket moved to *In Review* status
