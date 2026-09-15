# Store listing — AquaMind

Single source of truth for the public naming. The app name is set in code
(`android/app/build.gradle.kts` `resValue app_name`, `ios/Runner/Info.plist`
`CFBundleDisplayName`); everything below is typed into the consoles by hand, so
it lives here to keep the two in step.

## Name

| Where | Value |
| --- | --- |
| Launcher / display name | `AquaMind` |
| Google Play title (max 30) | `AquaMind: Water & AI Coach` — 26 ✅ |
| App Store name (max 30) | `AquaMind: Water & AI Coach` — 26 ✅ |
| Google Play short description (max 80) | `Smart hydration tracker with AI guidance` — 40 ✅ |
| App Store subtitle (max 30) | ⚠️ the 40-char line above does **not** fit — see below |

### App Store subtitle

Apple caps the subtitle at 30 characters, so the short description has to be
trimmed for iOS. Pick one:

- `Smart hydration + AI coach` — 26
- `Hydration tracker with AI` — 25
- `Smart water tracker with AI` — 27

## Identifiers — do not change

Renaming any of these ships as a different app: existing installs, reviews,
ratings and purchases do not carry over.

| Identifier | Value |
| --- | --- |
| Android `applicationId` | `com.dsp.smartdrinkai` |
| Android Kotlin package | `com.amobi.drinkwater.water_nudge` |
| iOS bundle id | `$(PRODUCT_BUNDLE_IDENTIFIER)` (Xcode) |
| Dart package name | `waternudge` (internal, appears in every import) |

## Privacy policy

<https://asctechsoft.com/privacy/policy-aquamind/>

Server-rendered, AquaMind-branded, write-only Health Connect wording. Matches
the app as shipped. Contact address on the page is contact@asctechsoft.com.
