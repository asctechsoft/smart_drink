# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Drink Water is a Flutter app for tracking daily water intake. It supports Android and iOS, with an 8-step onboarding flow, daily drink logging, history charts, reminders, and home screen widgets.

## Commands

```bash
# Run the app
flutter run

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Analyze for errors
flutter analyze

# Format code
dart format .

# Get dependencies (run after pubspec changes)
flutter pub get
```

## Architecture

**State Management & Routing:** GetX (`get` package) — controllers extend `GetxController`, routes use `GetMaterialApp` with named `GetPage` entries defined in `lib/main.dart`, route constants in `lib/values/route_name.dart`.

**Permanent controllers** (survive route changes, bound in `main.dart`'s `initialBinding`):
- `SettingsController` — theme, language, units
- `UserProfileController` — user profile and daily goal

**Route-scoped controllers** (bound via `GetPage.binding`):
- `TodayController` — bound when entering home screen

**Layer structure:**
```
Presentation (lib/presentation/)  →  screens & reusable widgets
Controllers  (lib/controller/)    →  GetX reactive state
Services     (lib/services/)      →  business logic, native bridges
Repository   (lib/repository/)    →  data access
Storage      (lib/services/storage/) → SQLite via sqflite (singleton DatabaseHelper)
```

**Database:** SQLite (`drink_water.db`) with tables: `user_profile`, `drink_record` (indexed on `date_key`), `daily_summary`, `reminder_schedule`. Schema defined in `lib/services/storage/schema.dart`.

**Native platform channels:**
- `com.amobi.drinkwater/notifications` — reminder scheduling
- `com.amobi.drinkwater/widget` — home screen widget updates

**Local dependency:** `amobi_common` (path: `./amobi_common`) — shared package providing UI components (`AppText`, `AppBox`, `AppRow`, etc.), localization (XML-based, 60+ languages), ad controllers, Firebase utilities, GDPR consent, and permission helpers.

## Key Directories

- `lib/models/data_models/` — database-backed models (UserProfile, DrinkRecord, DailySummary, ReminderSchedule)
- `lib/models/ui_models/` — enums and UI data (DrinkType, ActivityLevel, WeatherCondition, ReminderMode)
- `lib/values/` — design tokens (AppTheme, AppColors), route names
- `lib/configs/` — SharedPreferences key constants and defaults
- `lib/utils/` — helpers (WaterCalculation, UnitConverter, DateUtils, extensions)
- `lib/presentation/common_components/` — reusable widgets (ProgressRing, WheelPicker, PrimaryButton, etc.)

## Conventions

- Linting: `package:flutter_lints/flutter.yaml` (see `analysis_options.yaml`)
- Dart SDK: `^3.9.2`
- Material Design 3 theming with light/dark support
- Preference keys centralized in `lib/configs/pref_const.dart` with defaults in `pref_defaults.dart`
- Models use `copyWith` pattern for immutability
- ISO8601 datetime strings and `date_key` (YYYY-MM-DD) for date-based queries
