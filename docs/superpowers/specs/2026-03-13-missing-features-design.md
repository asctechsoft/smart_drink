# Missing Features — Design Spec

**Date:** 2026-03-13
**Status:** Approved
**Approach:** Layered implementation (independent units in dependency order)

---

## 1. Quick Wins

### 1a. Delete Duplicate File

Remove `lib/presentation/screens_reminder/reminder_settings_screen copy.dart`.
Note: filename contains a space — shell commands must quote the path.

### 1b. Feedback — Email via `url_launcher`

- Add `url_launcher` to `pubspec.yaml`
- In `FeedbackScreen._onSend()`, construct a `mailto:` URI using `Uri(scheme: 'mailto', ...)` for proper encoding of special characters in subject/body
  - **To:** `feedback@drinkwater.app` (configurable constant)
  - **Subject:** title field text
  - **Body:** feedback field text + device info (platform, OS version from `Platform.operatingSystemVersion`)
- Call `launchUrl()` to open the mail client
- Keep the existing snackbar as a fallback if `launchUrl` fails
- No additional packages needed for device info — use `dart:io` `Platform` class

### 1c. IAP — Scaffolded Purchase Service

- Add `in_app_purchase` to `pubspec.yaml`
- New `lib/services/purchase_service.dart`:
  - Singleton pattern, initializes `InAppPurchase.instance`
  - `fetchProducts()` with placeholder product ID `com.amobi.drinkwater.premium_weekly`
  - `buyProduct()`, `restorePurchases()`
  - `isPremium` reactive state (`RxBool`) persisted in SharedPreferences
  - **Lazy stream subscription** — only subscribe to the purchase stream when `init()` is called, not at construction. The controller calls `init()` when needed (premium screen opened or checking restore at startup).
  - Properly calls `completePurchase()` on delivered purchases to avoid re-delivery
  - Error handling for `PurchaseStatus.error` and `PurchaseStatus.canceled`
- New `lib/controller/purchase_controller.dart`:
  - Permanent controller bound in `initialBinding`
  - Calls `purchaseService.init()` lazily on first access
  - Exposes `isPremium`, `isLoading`, `products` observables
  - Methods: `purchase()`, `restore()`
- Wire premium screen:
  - "Try for Free" button → `purchaseController.purchase()`
  - "Restore" button → `purchaseController.restore()`
- Add pref constants: `PrefConst.isPremium` with default `false`

**Future requirements (out of scope for scaffold):**
- Configure product IDs in App Store Connect / Google Play Console
- Server-side receipt validation for auto-renewable subscriptions
- StoreKit configuration file for iOS sandbox testing

---

## 2. iOS Notifications

Handle method channel `com.amobi.drinkwater/notifications` in `AppDelegate.swift`.

### Method Mapping (Complete)

| Method | Parameters | iOS Implementation |
|---|---|---|
| `requestPermission` | — | `UNUserNotificationCenter.requestAuthorization(options: [.alert, .sound, .badge])` → returns `Bool` |
| `scheduleReminder` | `id`, `time`, `title`, `body`, `sound?`, `vibrate` | `UNCalendarNotificationTrigger` with parsed time → individual notification with string identifier `"reminder_\(id)"` |
| `cancelReminder` | `id` | `removePendingNotificationRequests(withIdentifiers: ["reminder_\(id)"])` |
| `cancelAll` | — | `removeAllPendingNotificationRequests()` |
| `scheduleDailyNotification` | `morningHour`, `afternoonHour`, `nightHour` | 3× `UNCalendarNotificationTrigger` with `DateComponents(hour:)` for morning, afternoon, night |
| `cancelDailyNotification` | — | `removePendingNotificationRequests(withIdentifiers: ["daily_morning", "daily_afternoon", "daily_night"])` |
| `startOngoingNotification` | — | No-op (iOS doesn't support persistent notifications) |
| `stopOngoingNotification` | — | No-op |
| `updateOngoingData` | `currentMl`, `goalMl`, `lastDrinkText` | Update app badge: `max(0, ceil((goalMl - currentMl) / 250))` — glasses remaining. Clear to 0 when goal met. |
| `checkPendingAddWater` | — | Read/clear flag from `UserDefaults` → returns `Int` |
| `setFullScreenIntentEnabled` | `enabled` | No-op (Android-only concept) |
| `getFcmToken` | — | Return empty string (Firebase initialization is out of scope for this step; intentionally stubbed) |

### Key Decisions

- No new Dart code needed — existing `NotificationChannel` class already calls the right methods with `MissingPluginException` fallbacks
- `scheduleReminder`, `cancelReminder`, `cancelAll` are also unimplemented on Android currently (the Dart code catches `MissingPluginException`). This iOS implementation brings iOS to feature parity with the Dart API, ahead of Android.
- Badge count formula: `max(0, ceil((goalMl - currentMl) / 250))` — shows glasses remaining. When remaining is very small (e.g. 1ml), badge shows 1 — intentional as a "almost done" motivator.
- Notifications use default iOS sound
- `UNUserNotificationCenter.delegate` set to `self` in `AppDelegate` for foreground notification handling
- `cancelDailyNotification` removes by specific identifiers (not `removeAll`) to avoid cancelling per-reminder notifications

---

## 3. iOS Home Screen Widgets (WidgetKit)

### Xcode Project Configuration

1. Add Widget Extension target: **File > New > Target > Widget Extension** → name: `DrinkWaterWidget`
2. Deployment target: **iOS 14.0** (minimum for WidgetKit)
3. Enable **App Groups** capability on both `Runner` and `DrinkWaterWidget` targets
4. Add App Group identifier: `group.com.amobi.drinkwater` to both targets' entitlements
5. Add `CFBundleURLTypes` entry in `Info.plist` for `drinkwater` URL scheme (deep links from widgets)
6. Update `Podfile` if widget extension needs shared CocoaPods dependencies

### Data Flow

1. Flutter calls `updateWidgetData` on widget channel
2. `AppDelegate` writes data to `UserDefaults(suiteName: "group.com.amobi.drinkwater")`
3. Calls `WidgetCenter.shared.reloadAllTimelines()`
4. Widget extension reads from shared `UserDefaults`

### App Group

`group.com.amobi.drinkwater` — shared between main app and widget extension.

### Widget Types

| Widget | WidgetKit Size | Content |
|---|---|---|
| Small A | `.systemSmall` | Progress ring + current/goal ml |
| Small B | `.systemSmall` | Percentage + quick-add button |
| Medium A | `.systemMedium` | Progress ring + recent drinks list |
| Medium B | `.systemMedium` | Progress bar + next reminder time |
| Large | `.systemLarge` | Full dashboard — ring, recent drinks, quick-add |

### Method Channel Mapping

| Method | iOS Implementation |
|---|---|
| `updateWidgetData` | Write to shared `UserDefaults` + `WidgetCenter.shared.reloadAllTimelines()` |
| `requestPinWidget` | Return `false` (iOS doesn't support programmatic pinning) |

### Key Details

- Widget extension target: `DrinkWaterWidget`
- Use `StaticConfiguration` for iOS 14-16 compatibility. Note: deprecated in iOS 17 — future update can migrate to `AppIntentConfiguration`.
- SwiftUI views (required by WidgetKit)
- Deep links from widget taps → `drinkwater://add` URL scheme to open app
- Existing `WidgetPreviewScreen` in settings does not need changes — it shows conceptual previews, not live iOS widget renders

---

## 4. Tests

### Test Infrastructure

- Mock `DatabaseHelper` and repositories with in-memory implementations
- Mock platform channels (notification + widget) using `TestDefaultBinaryMessengerBinding` to verify calls without native code
- Mock `InAppPurchase.instance` using `InAppPurchasePlatform.instance` setter for purchase controller tests
- Shared test fixtures for `UserProfile`, `DrinkRecord`, `DailySummary`
- **GetX setup:** call `Get.testMode = true` in `setUp()`, and `Get.reset()` in `tearDown()` for proper controller lifecycle
- Add `integration_test` package to `dev_dependencies` in `pubspec.yaml`

### Controller Tests

| Controller | Key Test Cases |
|---|---|
| `TodayController` | addDrink updates totals, progress calculation, widget channel called on changes |
| `SettingsController` | Theme/language/unit switching persists and applies correctly |
| `HistoryController` | Period navigation (day/week/month), data aggregation, date range calculations |
| `ReminderController` | Mode switching, schedule generation for standard/interval/custom |
| `PurchaseController` | Premium state, product fetching, restore flow |
| `OnboardingController` | Step navigation, goal calculation from profile data |
| `LanguagesController` | Language switching, history tracking, suggested locales |

### Widget Tests

| Screen | Key Test Cases |
|---|---|
| `TodayScreen` | Progress ring shows, quick-add buttons work, drink list renders |
| `HistoryScreen` | Tab switching (day/week/month), chart renders, drink items display |
| `AddDrinkScreen` | Drink type selection, amount picker, save triggers controller |
| `SettingsScreen` | All tiles render, navigation to sub-screens works |
| `PremiumScreen` | Feature comparison table renders, buttons are tappable |
| `FeedbackScreen` | Text fields work, send button enables only when both fields filled |

### Integration Tests

Uses `integration_test` package (added to `dev_dependencies`). Tests run on-device/simulator.

| Flow | Steps |
|---|---|
| Onboarding → Home | Complete onboarding steps → land on home with calculated goal |
| Add Drink → History | Add a drink → verify in today's list and history |
| Settings Round-trip | Change theme/language/units → verify persistence after restart |
