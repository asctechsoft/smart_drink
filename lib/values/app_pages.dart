import 'package:get/get.dart';
import '../controller/onboarding_controller.dart';
import '../controller/reminder_controller.dart';
import '../controller/languages_controller.dart';
import '../presentation/screen_splash/splash_screen.dart';
import '../presentation/screens_onboarding/language_selection_screen.dart';
import '../presentation/screens_onboarding/welcome_screen.dart';
import '../presentation/screens_onboarding/gender_screen.dart';
import '../presentation/screens_onboarding/height_screen.dart';
import '../presentation/screens_onboarding/weight_screen.dart';
import '../presentation/screens_onboarding/weather_screen.dart';
import '../presentation/screens_onboarding/wakeup_screen.dart';
import '../presentation/screens_onboarding/bedtime_screen.dart';
import '../presentation/screens_onboarding/building_schedule_screen.dart';
import '../presentation/screen_home/home_screen.dart';
import '../presentation/screen_today/add_drink_screen.dart';

import '../presentation/screens_settings/widget_preview_screen.dart';
import '../presentation/screens_settings/theme_screen.dart';
import '../presentation/screens_settings/feedback_screen.dart';
import '../presentation/screens_settings/language_screen.dart';
import '../presentation/screens_settings/premium_screen.dart';
import '../presentation/screens_reminder/reminder_settings_screen.dart';
import '../presentation/screen_streak/streak_screen.dart';
import '../presentation/screen_avatar/avatar_screen.dart';
import '../controller/streak_controller.dart';

import 'route_name.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(name: RouteName.splash, page: () => const SplashScreen()),
    GetPage(
      name: RouteName.onboardingLanguage,
      page: () => const LanguageSelectionScreen(),
      binding: BindingsBuilder(() {
        Get.put(LanguagesController());
      }),
    ),
    GetPage(
      name: RouteName.welcome,
      page: () => const WelcomeScreen(),
      binding: BindingsBuilder(() {
        Get.put(OnboardingController());
      }),
    ),
    GetPage(name: RouteName.onboardingGender, page: () => const GenderScreen()),
    GetPage(name: RouteName.onboardingHeight, page: () => const HeightScreen()),
    GetPage(name: RouteName.onboardingWeight, page: () => const WeightScreen()),
    GetPage(
      name: RouteName.onboardingWeather,
      page: () => const WeatherScreen(),
    ),
    GetPage(name: RouteName.onboardingWakeup, page: () => const WakeupScreen()),
    GetPage(
      name: RouteName.onboardingBedtime,
      page: () => const BedtimeScreen(),
    ),
    GetPage(
      name: RouteName.onboardingBuildingSchedule,
      page: () => const BuildingScheduleScreen(),
    ),
    GetPage(name: RouteName.home, page: () => const HomeScreen()),
    GetPage(name: RouteName.addDrink, page: () => const AddDrinkScreen()),

    GetPage(
      name: RouteName.widgetPreview,
      page: () => const WidgetPreviewScreen(),
    ),
    GetPage(name: RouteName.themeSelection, page: () => const ThemeScreen()),
    GetPage(
      name: RouteName.reminderSettings,
      page: () => const ReminderSettingsPage(),
      binding: BindingsBuilder(() {
        Get.put(ReminderController());
      }),
    ),
    GetPage(
      name: RouteName.streak,
      page: () => const StreakScreen(),
      binding: BindingsBuilder(() {
        Get.put(StreakController());
      }),
    ),
    GetPage(name: RouteName.avatarSelection, page: () => const AvatarScreen()),
    GetPage(name: RouteName.feedback, page: () => const FeedbackScreen()),
    GetPage(name: RouteName.premium, page: () => const PremiumScreen()),
    GetPage(
      name: RouteName.languageSelection,
      page: () => const LanguageScreen(),
      binding: BindingsBuilder(() {
        Get.put(LanguagesController());
      }),
    ),
  ];
}
