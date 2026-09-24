# Analytics & guided-tour A/B logging

Event logging for AquaMind, ported from Money Management's guided-tour A/B
logging pattern (`D:\money_management\docs\guided-tour-ab-logging.md`). That
doc is the canonical reference for *how* this shape works and *why*; this file
is the AquaMind-specific spec: every event name, its parameters, and where it
fires. Read the porting doc first if something here is unclear — the
"porting checklist" at its end is what this file was built against.

---

## 1. The shape of the thing

Three pieces (AquaMind has no A/B-branched screen-walkthrough split into
per-screen groups the way Money Management's tour does — one screen, one
group — so it's three pieces, not five):

| Piece | File | Job |
|---|---|---|
| Analytics gateway | `lib/utils/analytics.dart` | Validates names, buckets numbers to strings, routes to Firebase, swappable in tests |
| Route-view logger | `lib/utils/route_analytics.dart` | Logs a screen-view event for every named-route navigation, from one place |
| Guided tour | `lib/tour/` (`tour_steps.dart`, `tour_anchor.dart`, `tour_controller.dart`, `tour_overlay.dart`) | The Today-screen walkthrough, with a real A/B branch |

**One deliberate departure from the Money Management reference**: that app
encodes the A/B branch *in the event name* (`report_variant2_step1_view`).
Here the branch rides as a `variant` parameter on one event name instead
(`tour_today_step1_view` + `{variant: plain}`). This is the GA4-idiomatic
shape and it halves the distinct-event-name cost against GA4's 500-name/
project cap — the porting doc calls this exact trade-off out in its "things
that will bite you" section. Every other event in this app (not just the
tour) follows the same one-name-plus-parameters shape for the same reason.

---

## 2. The gateway (`lib/utils/analytics.dart`)

```
Analytics.someEvent(...)
  └─ _log(name, params)
       ├─ assert isValidEventName(name)          — ≤40 chars, starts with a letter, no firebase_/google_/ga_ prefix
       ├─ assert params are all String            — GA4 custom dimensions drop numbers silently
       ├─ if invalid: return (release), never crash
       └─ _eventSink(name, params)
            ├─ production → FirebaseAssist.logCustomEvent (dsp_base)
            └─ tests      → setEventSinkForTest(...)   — no platform channel
```

`FirebaseAssist.logCustomEvent`/`setUserProperty` (added to
`dsp_base/lib/utils/firebase_assist.dart` alongside the existing
`logBttnClicked`/`logScreenView` helpers) are the only things that touch
`FirebaseAnalytics` directly, and both are gated on
`FirebaseAssist.isAnalyticsEnabled` — the same GDPR consent switch every other
event in the app already respects.

**Numbers are bucketed, never sent raw.** `volumeBucket`, `goalBucket`,
`percentBucket`, `countBucket` turn an `int` into a low-cardinality band
string (e.g. `750-999`, `100-149`). Renaming a band is exactly as breaking as
renaming an event — GA4 has no rename, so band edges are settled once.

---

## 3. Screen views: two different mechanisms, on purpose

**Named-route screens** (`lib/utils/route_analytics.dart`, wired to
`CommApp.routingCallback` in `main.dart`) — onboarding's 10 steps, Streak,
Feedback, Avatar selection, Widget preview. One central switch on
`routing.current`, deduped so GetX's multiple routing-callback firings per
navigation don't double-log.

**Tab screens inside `HomeScreen`** (Today/History/Reminders/Settings) are
*not* routes — they live in one `IndexedStack` — so `RouteAnalytics` never
sees them. Their views are logged from `HomeScreen._select`/`initState`
instead, keyed off the same tab-slug list the nav-tap event uses.

Two screens need a `source` the route alone can't supply (chat, premium) —
those log their own view at the navigation call site instead of through
either mechanism above.

---

## 4. Event reference

Every event name and parameter set actually implemented in
`lib/utils/analytics.dart`. Grouped the way the gateway is. A `—` parameter
column means the event carries none.

### User properties

| Property | Values | Set from |
|---|---|---|
| `language` | locale key (`en_US`, `vi`, …) | `LanguagesController.changeLanguage` |
| `theme` | `light` / `dark` / `system` | `SettingsController.loadSettings` |
| `volume_unit` | `ml` / `oz` | `SettingsController.loadSettings` |
| `weight_unit` | `kg` / `lb` | `SettingsController.loadSettings` |
| `gender` | `male` / `female` | `UserProfileController.saveProfile` |
| `daily_goal_bucket` | goal band | `UserProfileController.saveProfile` |
| `reminder_enabled` | `0`/`1` | `ReminderController.saveSettings` |
| `reminder_mode` | `standard`/`interval`/`custom` | `ReminderController.saveSettings` |
| `health_connect_enabled` | `0`/`1` | `SettingsController.loadSettings` |
| `is_logged_in` | `0`/`1` | `AuthController` (`ever(user, …)`) |
| `streak_bucket` | count band | `StreakController.loadStreakData` |
| `tour_variant` | `pulse`/`plain` | `TourController.startGroup` |

`userIsPremium`, `userDrinkCount`, `userAvatar`, `userPermNotification`,
`userOpenAppInDayN` are defined for when premium/avatar/notification-permission
tracking is wired up (see §6) but not yet called.

### App lifecycle

| Event | Params | Fires |
|---|---|---|
| `app_open` | `source`, and only on first open no extra param | `SplashScreen.initState` |
| `splash_view` | — | `SplashScreen.initState` |
| `splash_end` | `destination` (`home`/`onboarding`) | `SplashScreen._navigate`, right before routing away |

### Onboarding

| Event | Params | Fires |
|---|---|---|
| `onboarding_view` | `step` | `RouteAnalytics`, one per onboarding route |
| `onboarding_next_tap` | `step` | Each screen's primary button, before navigating on |
| `onboarding_gender_select` | `gender` | `GenderScreen` tap |
| `onboarding_height_set` | `unit` | `OnboardingController.updateHeightUnit` |
| `onboarding_weight_set` | `unit` | `OnboardingController.updateWeightUnit` |
| `onboarding_weather_select` | `condition` | `WeatherScreen` tap |
| `onboarding_wakeup_set` | — | `WakeupScreen` next tap |
| `onboarding_bedtime_set` | — | `BedtimeScreen` next tap |
| `onboarding_nap_toggle` | `enabled` | `NapScreen` next tap |
| `onboarding_goal_view` | `goal_bucket` | `DailyGoalResultScreen.build` |
| `onboarding_complete` | `goal_bucket` | `OnboardingController.completeOnboarding` |
| `language_select` | `language` | `LanguagesController.changeLanguage` — shared with the settings language sheet, see §3 |
| `noti_permission_first_view` | — | `BuildingScheduleScreen.initState`, before the OS prompt |
| `noti_permission_first_accept` / `noti_permission_first_deny` | — | Same, after the OS prompt resolves |

### Navigation

| Event | Params | Fires |
|---|---|---|
| `nav_today_tap` / `nav_history_tap` / `nav_reminders_tap` / `nav_settings_tap` | — | `HomeScreen._select`, only on an actual tab change |

### Today

| Event | Params | Fires |
|---|---|---|
| `today_view` | — | `HomeScreen` tab 0 shown |
| `drink_add_tap` | `source` (`action_bar`/`quick_add_button`) | Before the 8000 ml guard, so a refused tap still counts as intent |
| `drink_add_success` | `drink_type`, `amount_bucket`, `progress_bucket`, `source` | `TodayController.addDrink`, after the record is written |
| `drink_goal_reached` | `goal_bucket` | Same method, the crossing edge only |
| `drink_type_select` | `drink_type` | Drink-type picker sheet |
| `drink_amount_select` | `amount_bucket` | Cup-size picker sheet |
| `add_drink_view` | — | `AddDrinkScreen._showDrinkBottomSheet` |

`source` values in use: `action_bar` (the `+amount` pill), `add_drink_screen`,
`quick_add_button`.

### History

| Event | Params | Fires |
|---|---|---|
| `history_view` | — | `HomeScreen` tab 1 shown |
| `history_period_select` | `period` (`day`/`week`/`month`/`year`) | Period-tab tap in `HistoryScreen` |
| `history_period_change` | `direction`, `period` | `HistoryController.previousPeriod`/`nextPeriod` |
| `history_back_to_today` | — | `HistoryController.backToToday` |
| `history_record_edit` | — | `HistoryController.updateRecord` |
| `history_record_delete` | — | `HistoryController.deleteRecord` |

### Streak

| Event | Params | Fires |
|---|---|---|
| `streak_view` | — | `RouteAnalytics` on entering `RouteName.streak` |
| `streak_month_change` | `direction` | `StreakController.previousMonth`/`nextMonth` |

### Reminder

| Event | Params | Fires |
|---|---|---|
| `reminder_view` | — | `HomeScreen` tab 2 shown |
| `reminder_toggle` | `enabled` | Master toggle in `SettingsScreen` |
| `reminder_mode_select` | `mode` | `ReminderController.setMode` |
| `reminder_slot_add` / `_edit` / `_delete` | — | `ReminderController.addSchedule`/`updateSchedule`/`removeSchedule` |
| `reminder_save` | `mode`, `slot_count_bucket` | `ReminderController.saveSettings` |

`reminderIntervalSelect`, `reminderSleepTimeSet`, `reminderSoundSelect`,
`reminderNotiOpen` are defined for the interval/sleep/sound editors and the
ongoing-reminder notification tap, not yet wired — see §6.

### Settings

| Event | Params | Fires |
|---|---|---|
| `settings_view` | — | `HomeScreen` tab 3 shown |
| `settings_row_tap` | `row` (`daily_goal`/`weather`/`gender`/`height`/`weight`/`wakeup`/`bedtime`/`nap`/`units`/`language`/`feedback`) | Each row's `onTap` in `SettingsScreen`, before the sheet opens |
| `settings_theme_select` | `theme` | `SettingsController.setThemeMode` (not yet reachable from UI — theme picker unwired) |
| `settings_unit_select` | `kind` (`volume`/`weight`/`height`), `unit` | `SettingsController.setVolumeUnit`/`setWeightUnit`/`setHeightUnit` |
| `settings_field_save` | `field` (`gender`/`weather`/`height`/`weight`/`wakeup`/`bedtime`/`activity_level`), `value` | `UserProfileController`'s per-field `update*` methods |
| `settings_goal_edit` | `goal_bucket` | `UserProfileController.updateDailyGoal` |
| `settings_health_connect_toggle` | `enabled`, `success` | `SettingsScreen._onHealthConnectChanged` |
| `settings_rate_tap` | — | Rate-app row tap |
| `settings_rate_submit` | `stars` | `RateAppDialog._onSubmit` |
| `settings_share_tap` | — | Share row tap |
| `feedback_view` | — | `RouteAnalytics` on entering `RouteName.feedback` |
| `feedback_submit` | `has_text` | `FeedbackScreen._onSend` |
| `widget_preview_view` | — | `RouteAnalytics` on entering `RouteName.widgetPreview` (route currently unreached from UI) |

### Avatar

| Event | Params | Fires |
|---|---|---|
| `avatar_view` | — | `RouteAnalytics` on entering `RouteName.avatarSelection` (route currently unreached from UI) |

`avatarSelect`/`avatarSave` are defined, not yet wired — see §6.

### AI chat

| Event | Params | Fires |
|---|---|---|
| `chat_view` | `source` (`today_header`) | Before `Get.toNamed(RouteName.chatBot)` |
| `chat_send` | `is_suggestion`, `quota_left` | `ChatController.send` |
| `chat_response_success` | — | `ChatController._request`, stream closed with a card |
| `chat_response_fail` | `reason` (`AiChatException.code`) | Same, on a thrown `AiChatException` |
| `chat_retry` | — | `ChatController.retry` |
| `chat_new` | — | `ChatController.newChat` |
| `chat_quota_exhausted` | — | `ChatController.send`, refused before a turn is appended |

### Auth

| Event | Params | Fires |
|---|---|---|
| `login_tap` / `login_success` / `login_fail` | `method` (`google`) | `AuthController.signInWithGoogle` |
| `logout` | — | `AuthController.signOut` |

### Premium (defined, not yet wired)

`premiumView(source)`, `premiumPurchaseTap`, `premiumPurchaseSuccess` exist in
the gateway for when `RouteName.premium` gets a real entry point and an IAP
flow. Route currently unreached from UI.

---

## 5. The guided tour (`lib/tour/`)

Ported line-for-line from the porting doc's shape (`tourSteps` table +
permanent `TourController` + `TourAnchor` + `TourOverlay` mounted above the
navigator), replacing the ad-hoc `showCoachMarks` walkthrough that used to
live directly in `TodayScreen` (deleted:
`lib/presentation/common_components/coach_mark.dart`).

**One group, three steps** — the Today screen's `+amount` pill →
drink-type card → AI chat shortcut, same three targets the old coach-mark
spotlighted. `TourGroup` is still an enum (`TourGroup.today` today) so a
second screen's tour slots in later the same way, per the porting doc's
`startGroup(group)` pattern.

**A/B branch**: `TourController.variantPulse` (current visuals — the
`+amount` pill's clone scales up and pulses in place) vs `variantPlain` (every
step gets a plain highlight hole, no clone/pulse animation). This is a real
rendering difference worth testing, not a placebo — `variantPlain` is the
lighter-weight path for `CommFigs.IS_WEAK_DEVICE`.

**Assignment**: `TourController.assignLocalVariant()` (called from
`main.dart`'s `onBindingInitialized`) flips a coin once per install, stores it
under `PrefConst.tourAbVariant`, and pins it into `RconfAssist`'s test
override — which is itself a no-op on the Product release build
(`CommFigs.IS_SHOW_TEST_OPTION`), so shipping this can never overwrite a real
Remote Config experiment. Swap the coin flip for a real `TOUR_VARIANT` Remote
Config key when the experiment exists; nothing else in `TourController`
changes.

**Trigger flag**: reuses `PrefConst.coachMarkHomeSeen` (the old coach-mark's
pref key) rather than inventing a new one, so an install that already
dismissed the walkthrough doesn't see it again.

### Tour events

One event name per step/action, `variant` as a parameter — not per-branch
name encoding (see §1 for why):

```
tour_today_step{1,2,3}_view
tour_today_step{1,2,3}_next_tap        — steps 1–2
tour_today_step3_gotit_tap             — last step's primary button
tour_today_step{2,3}_previous_tap      — never step 1, the Previous button isn't rendered there
tour_today_step{1,2,3}_close_tap       — the X button, any step
```

All six emit `{"variant": "pulse"}` or `{"variant": "plain"}`. `_logStepAction`
is the single funnel every caller (`next`/`previous`/`skip`/`startGroup`)
routes through, reading `step` off the controller's own `index` — no caller
passes the step or action in from outside itself, matching the porting doc's
"no caller ever passes which screen or step" rule.

**Action fires before view, same as the reference**: `next()` logs
`stepN_next_tap` *then* advances the index and logs `step(N+1)_view` — one tap
can emit two events.

### Auto-advance

Ported from the porting doc's "not every `next_tap` is a tap" gotcha:
`TourOverlay` auto-advances (a real `next_tap`/`gotit_tap` event, no user
action behind it) if a step's anchor doesn't lay out within 10 seconds. First
place to check if the Today tour's completion rate looks too good.

---

## 6. Not yet wired

Gateway methods exist but nothing calls them yet — either the screen is
currently unreached from any navigation in the app (`premium`,
`avatarSelection`, `themeSelection` — verified with a repo-wide grep for
`Get.to`/`Get.toNamed` against each route name) or the feature itself isn't
built (in-app purchases). Wire these when the screen gets a real entry point;
don't delete the methods in the meantime — a spec entry with no caller is a
cheaper mistake than rediscovering the right event name later.

- `Analytics.premiumView/premiumPurchaseTap/premiumPurchaseSuccess`
- `Analytics.avatarSelect/avatarSave`
- `Analytics.settingsThemeSelect` (defined and called from
  `SettingsController.setThemeMode`, but nothing in `SettingsScreen` opens a
  theme picker yet — the app ships one fixed dark theme, see
  `WaterNudgeApp`'s comment in `main.dart`)
- `Analytics.reminderIntervalSelect/reminderSleepTimeSet/reminderSoundSelect/reminderNotiOpen`
- `Analytics.userIsPremium/userDrinkCount/userAvatar/userPermNotification/userOpenAppInDayN`

---

## 7. Testing

`test/utils/analytics_test.dart` and `test/tour/tour_controller_test.dart`
mirror the porting doc's three layers:

1. **Behaviour** — exact event sequence for a walk through the tour,
   including the action-before-view ordering and the previous/skip guards.
2. **Spec mirror** — walk every step × branch × exit path, collect the
   distinct event names, compare by **set equality** against the literal list
   in §5 (typed out, not generated — see the porting doc's rationale: a
   generated loop never appears as a greppable string, so `Ctrl-F` on an event
   name from this doc finds nothing).
3. **Mutation** — not automated; per the porting doc, break a branch of
   `_logStepAction`'s variant selection on purpose and confirm the spec-mirror
   test goes red before reverting. Do this once after changing the tour.

`Analytics.setEventSinkForTest`/`resetEventSinkForTest` swap the sink so no
test reaches the Firebase platform channel.

Verifying on a real device — Firebase DebugView shows events in real time:

```
adb shell setprop debug.firebase.analytics.app com.amobi.drinkwater
```
