# AGENTS.md

Practical guidance for AI agents working on JiraBar.

## Project Snapshot

- Native macOS menu bar app (single Xcode target, Swift 5)
- Polls Jira REST API on a timer and renders issues in an `NSMenu`
- `AppDelegate` is the central coordinator for menu lifecycle and refresh logic
- SwiftUI is used for Preferences and About windows only

## High-Signal Files

- `JiraBar/AppDelegate.swift`: status bar lifecycle, timer, menu rebuild, window hosting
- `JiraBar/Jira/JiraClient.swift`: Jira API calls, auth headers, credential validation
- `JiraBar/Views/PreferencesView.swift`: Cloud/Server settings UI and Test button behavior
- `JiraBar/Extensions/DefaultsExtensions.swift`: Defaults keys, enums, Keychain keys
- `JiraBar/Keychain.swift`: `@FromKeychain` / `@KeychainStorage` wrappers

## Auth and Instance Model

- `instanceType`: `.cloud` or `.server`
- `serverAuthType`: `.pat` or `.basic`
- Cloud:
  - Base URL: `https://{org}.atlassian.net`
  - API: v3 for search (`/rest/api/3/search/jql`)
  - Auth: Basic (`jiraUsername` + `jiraToken`)
- Server/Data Center:
  - Base URL: `jiraHost` (trim trailing slash)
  - API: v2 (`/rest/api/2/...`)
  - PAT: Bearer (`jiraServerToken`)
  - Basic: username/password (`jiraServerUsername` + `jiraServerToken`)

## Storage Rules

- Secrets stay in Keychain only (`jiraToken`, `jiraServerToken`)
- UserDefaults keys are defined in `DefaultsExtensions.swift`; do not invent ad-hoc keys
- Preserve existing key names unless a migration is explicitly requested

## Networking Conventions

- Use Alamofire with closure-based callbacks (current project style)
- Keep auth/header construction centralized in `JiraClient`
- Handle Cloud vs Server differences explicitly (URL, API version, auth type)

## Build and Verify

- Build command:
  - `xcodebuild -project jiraBar.xcodeproj -scheme jiraBar -destination 'platform=macOS' build`
- There are no tests. Manually verify:
  1. Menu bar icon appears and refreshes on interval
  2. Preferences save and reload correctly for Cloud and Server modes
  3. Issue grouping and transitions still work
  4. About and external links still open

## Current Tech Debt

- `sendNotification` exists in both `Notifications.swift` and `JiraClient.swift` (duplication)
- `unknownPersonAvatar` in `AppDelegate` is unused

## Entitlements

- Keep sandbox/network client entitlements as-is
- Do not add `com.apple.security.network.server`
