import 'package:get/get.dart';
import 'package:waternudge/utils/analytics.dart';
import 'package:waternudge/values/route_name.dart';

/// Logs a screen-view event for every named-route navigation, from one place,
/// instead of hand-instrumenting each screen's `initState`/`build`.
///
/// Wired into `CommApp.routingCallback` in `main.dart`. GetX's routing
/// callback fires more than once per navigation (push settles through a few
/// internal states), so this dedupes on the route string and skips overlays
/// (bottom sheets/dialogs) that reuse the current route name.
///
/// Tab screens inside `HomeScreen` (Today/History/Reminders/Settings) are NOT
/// routes — they live in one `IndexedStack` — so their views are logged from
/// `HomeScreen._select` instead. This callback only sees the routes in
/// `AppPages.pages`.
class RouteAnalytics {
  RouteAnalytics._();

  static String? _lastLoggedRoute;

  /// Slug used by [Analytics.onboardingView] for each onboarding route, in
  /// the order the flow visits them.
  static const Map<String, String> _onboardingSteps = {
    RouteName.onboardingLanguage: 'language',
    RouteName.welcome: 'welcome',
    RouteName.onboardingGender: 'gender',
    RouteName.onboardingHeight: 'height',
    RouteName.onboardingWeight: 'weight',
    RouteName.onboardingWeather: 'weather',
    RouteName.onboardingWakeup: 'wakeup',
    RouteName.onboardingNap: 'nap',
    RouteName.onboardingBedtime: 'bedtime',
    RouteName.onboardingBuildingSchedule: 'building_schedule',
  };

  static void onRouting(Routing? routing) {
    if (routing == null) return;
    if (routing.isBottomSheet == true || routing.isDialog == true) return;
    final route = routing.current;
    if (route.isEmpty || route == _lastLoggedRoute) return;
    _lastLoggedRoute = route;

    final onboardingStep = _onboardingSteps[route];
    if (onboardingStep != null) {
      Analytics.onboardingView(onboardingStep);
      return;
    }

    switch (route) {
      case RouteName.streak:
        Analytics.streakView();
      case RouteName.widgetPreview:
        Analytics.widgetPreviewView();
      case RouteName.avatarSelection:
        Analytics.avatarView();
      case RouteName.feedback:
        Analytics.feedbackView();
      // premium, chat and language-from-settings need a `source` the route
      // alone can't provide — those screens log their own view on entry.
    }
  }
}
