import 'dart:async';

import 'package:waternudge/utils/analytics.dart';

/// Runs before every test file in this suite.
///
/// `Analytics` defaults to sending real events through
/// `FirebaseAssist.logCustomEvent`, which needs a registered Firebase app.
/// No test in this suite calls `Firebase.initializeApp()`, so any test that
/// exercises code with an `Analytics.*` call in it — a controller's `onInit`,
/// a screen's `initState`, a button handler — would otherwise crash with
/// `[core/no-app] No Firebase App '[DEFAULT]' has been created`. Swapping the
/// sink to a no-op here, once, means individual test files never need to know
/// `Analytics` exists.
///
/// A test that wants to assert on emitted events calls
/// `Analytics.setEventSinkForTest(...)` itself and should reset with
/// `Analytics.resetEventSinkForTest()` in `tearDown` — that override applies
/// only within that file, on top of this default.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  Analytics.setEventSinkForTest((_, _) {});
  await testMain();
}
