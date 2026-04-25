# AGENTS.md

This file contains information for AI coding agents working on the JiraBar codebase.

## Project Overview

JiraBar is a native macOS menubar app that polls the Jira Cloud REST API on a configurable timer and renders issues as a native `NSMenu`. It is a single-target Xcode project written in Swift.

- **Version:** 1.3 (build 2)
- **Bundle ID:** `com.pavelmakhov.JiraBar`
- **Minimum macOS:** 13.0
- **Language:** Swift 5.0
- **Build system:** Xcode (`jiraBar.xcodeproj`) with Swift Package Manager for dependencies

## Repository Structure

```
JiraBar/
├── .github/
│   ├── FUNDING.yml                        # GitHub Sponsors config
│   └── workflows/
│       └── homebrew-cask-updates.yml      # CI: auto-bumps Homebrew cask on release
├── README.md
├── jiraBar.xcodeproj/                     # Xcode project
│   └── project.xcworkspace/swiftpm/
│       └── Package.resolved               # Pinned SPM dependency versions
└── JiraBar/                               # All source code
    ├── AppDelegate.swift                  # App entry point; owns the entire menu bar lifecycle
    ├── Keychain.swift                     # @KeychainStorage / @FromKeychain property wrapper
    ├── Notifications.swift                # UNUserNotificationCenter helper
    ├── JiraBar.entitlements               # Sandbox + network client entitlements
    ├── Assets.xcassets/
    ├── Base.lproj/Main.storyboard
    ├── Jira/
    │   ├── JiraClient.swift               # All Jira REST API calls (Alamofire)
    │   ├── JiraDtos.swift                 # Codable structs for Jira API responses
    │   └── JiraTokenValidator.swift       # ObservableObject for credential validation state
    ├── Github/
    │   ├── GithubClient.swift             # Latest-release check via GitHub API
    │   └── GithubDtos.swift               # Codable structs for GitHub API responses
    ├── Views/
    │   ├── PreferencesView.swift          # SwiftUI preferences panel
    │   ├── AboutView.swift                # SwiftUI about panel
    │   └── DebounceTextField.swift        # Debounced SwiftUI text field (Combine)
    └── Extensions/
        ├── DefaultsExtensions.swift       # All UserDefaults + Keychain key definitions
        ├── NSMutableAttributedString.swift # Fluent builder for rich menu item text
        ├── NSColorExtensions.swift        # NSColor(hex:) initializer
        ├── NSImageExtensions.swift        # NSImage tinting + URL image loading
        └── StringExtensions.swift         # String.trunc(length:trailing:) helper
```

## Architecture

### Core Pattern

The app uses a classic macOS menubar app pattern — `AppDelegate` as the central coordinator:

- `AppDelegate` owns the `NSStatusItem`, `NSMenu`, and a repeating `Timer` that polls Jira.
- On each tick, it calls `JiraClient`, groups issues by status using `Dictionary(grouping:)`, and rebuilds the entire `NSMenu`.
- Transition submenus are built lazily when an issue is hovered/clicked.
- `NSApp.setActivationPolicy(.accessory)` hides the app from the Dock and app switcher.

### SwiftUI Integration

SwiftUI is used **only** for the Preferences and About windows. Each is hosted via the standard AppKit bridge:

```swift
let window = NSWindow(...)
window.contentView = NSHostingView(rootView: PreferencesView())
```

### Settings and Secrets

- **UserDefaults** keys are all defined in `Extensions/DefaultsExtensions.swift` using the `Defaults` library (`sindresorhus/Defaults`). Access via `@Default(.keyName)`.
- **Keychain** is used for the API token exclusively. The custom `@FromKeychain` / `@KeychainStorage` property wrapper (in `Keychain.swift`) wraps `KeychainAccess` and conforms to `ObservableObject` so SwiftUI views update reactively.
- Never store sensitive credentials in `UserDefaults`.

### Networking

All HTTP calls use **Alamofire** with closure-based completion handlers (no `async/await`). There is no networking layer abstraction — `JiraClient.swift` and `GithubClient.swift` make direct `AF.request(...)` calls.

## Dependencies (SPM)

| Package | Pinned Version | Purpose |
|---|---|---|
| `Alamofire/Alamofire` | 5.5.0 | HTTP networking |
| `sindresorhus/Defaults` | 6.1.0 | Type-safe UserDefaults wrapper |
| `kishikawakatsumi/KeychainAccess` | master (pinned commit) | Keychain read/write |

Dependencies are managed via Xcode's SPM integration. To add or update a dependency, use Xcode → File → Add Package Dependencies, or edit `project.pbxproj` and update `Package.resolved`.

## Key Defaults Keys

All defined in `Extensions/DefaultsExtensions.swift`:

| Key | Type | Default | Description |
|---|---|---|---|
| `instanceType` | `JiraInstanceType` | `.cloud` | Whether the target is Jira Cloud or self-hosted Server/Data Center |
| `jiraUsername` | `String` | `""` | Jira account email (Cloud) or username (Server) |
| `orgName` | `String` | `""` | Atlassian org subdomain — used only when `instanceType == .cloud` |
| `jiraHost` | `String` | `"https://jira.example.com"` | Base URL — used only when `instanceType == .server` |
| `jql` | `String` | `""` | JQL query for fetching issues |
| `refreshRate` | `Int` | `5` | Poll interval in minutes |
| `maxResults` | `String` | `"10"` | Max issues returned per query |
| `jiraToken` (Keychain) | `String` | `""` | API token (Cloud) or password (Server) — stored in Keychain |

### Instance type logic (`JiraClient.swift`)

`JiraClient` exposes two private computed properties that all methods use:

```swift
var baseUrl: String  // "https://{org}.atlassian.net" | jiraHost (trimmed)
var apiVersion: String  // "3" for Cloud, "2" for Server (Server never supported v3)
```

Both `getIssuesByJql` and `getMyself` use `apiVersion`; the transitions endpoints always use v2 (consistent across both instance types).

## Known Issues / Tech Debt

- `sendNotification` is defined in **both** `Notifications.swift` and `JiraClient.swift` — the duplicate in `JiraClient.swift` should be removed.
- `Notifications.swift` has the notification title hardcoded as `"PullBar"` (copy-paste from a sibling project) — should be `"JiraBar"`.
- `unknownPersonAvatar` is declared and initialized in `AppDelegate` but never used.
- No tests exist anywhere in the project.

## Building

Open `jiraBar.xcodeproj` in Xcode 14+ and build with `Cmd+B` or run with `Cmd+R`. There is no Makefile or CLI build script.

SPM dependencies resolve automatically on first open. If they do not, use Xcode → File → Packages → Resolve Package Versions.

## Distribution

- **GitHub Releases:** The primary distribution channel. Tag a release on GitHub to trigger the Homebrew cask auto-update workflow.
- **Homebrew:** Available as `brew install --cask jirabar` via the `menubar-apps/homebrew-menubar-apps` tap.
- The CI workflow (`.github/workflows/homebrew-cask-updates.yml`) updates the cask automatically on new releases.

## Testing

There are **no tests** in this project. No test targets, no `XCTestCase` subclasses, no testing frameworks. When making changes, manually verify:

1. The menu bar icon appears and refreshes on the configured interval.
2. Preferences window opens, saves, and validates credentials correctly.
3. Issues group correctly by status in the menu.
4. Transitions submenu appears and can be triggered.
5. About window opens and links work.

## Entitlements

Defined in `JiraBar/JiraBar.entitlements`:

- `com.apple.security.app-sandbox` = `true`
- `com.apple.security.files.user-selected.read-only` = `true`
- `com.apple.security.network.client` = `true` (required for Jira + GitHub API calls)

Any new network hosts do not require additional entitlements — `network.client` covers outbound connections. Do not add `network.server`.
