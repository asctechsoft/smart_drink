import 'package:get/get.dart';
import '../controller/onboarding_controller.dart';
import '../controller/reminder_controller.dart';
import '../controller/languages_controller.dart';
import '../presentation/screen_splash/splash_screen.dart';
import '../presentation/screens_onboarding/welcome_screen.dart';
import '../presentation/screens_onboarding/gender_screen.dart';
import '../presentation/screens_onboarding/weight_screen.dart';
import '../presentation/screens_onboarding/wakeup_screen.dart';
import '../presentation/screens_onboarding/bedtime_screen.dart';
import '../presentation/screens_onboarding/reminder_settings_screen.dart';
import '../presentation/screens_onboarding/notification_permission_screen.dart';
import '../presentation/screens_onboarding/daily_goal_screen.dart';
import '../presentation/screen_home/home_screen.dart';
import '../presentation/screen_today/add_drink_screen.dart';

import '../presentation/screens_settings/widget_preview_screen.dart';
import '../presentation/screens_settings/theme_screen.dart';
import '../presentation/screens_settings/feedback_screen.dart';
import '../presentation/screens_settings/language_screen.dart';
import '../presentation/screens_settings/premium_screen.dart';
import '../presentation/screens_reminder/reminder_settings_screen.dart';
import 'route_name.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(name: RouteName.splash, page: () => const SplashScreen()),
    GetPage(
      name: RouteName.welcome,
      page: () => const WelcomeScreen(),
      binding: BindingsBuilder(() {
        Get.put(OnboardingController());
      }),
    ),
    GetPage(name: RouteName.onboardingGender, page: () => const GenderScreen()),
    GetPage(name: RouteName.onboardingWeight, page: () => const WeightScreen()),
    GetPage(name: RouteName.onboardingWakeup, page: () => const WakeupScreen()),
    GetPage(
      name: RouteName.onboardingBedtime,
      page: () => const BedtimeScreen(),
    ),
    GetPage(
      name: RouteName.onboardingReminder,
      page: () => const OnboardingReminderSettingsScreen(),
    ),
    GetPage(
      name: RouteName.onboardingNotification,
      page: () => const NotificationPermissionScreen(),
    ),
    GetPage(
      name: RouteName.onboardingDailyGoal,
      page: () => const DailyGoalScreen(),
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
