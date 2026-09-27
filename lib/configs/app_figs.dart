import 'package:flutter/services.dart';

/// App-owned replacement for dsp_base's `CommFigs` — build-flavor flags this
/// app actually reads. Matches the `--flavor` names declared in
/// `android/app/build.gradle.kts` (`alpha`, `dev`, `product`, `claude`).
class AppFigs {
  AppFigs._();

  static const bool isAlpha = appFlavor == 'Alpha' || appFlavor == 'alpha';
  static const bool isDev = appFlavor == 'Dev' || appFlavor == 'dev';
  static const bool isProduct =
      appFlavor == 'Product' || appFlavor == 'product';
  static const bool isClaude = appFlavor == 'Claude' || appFlavor == 'claude';

  /// Gates debug-only affordances (remote-config test overrides, forced test
  /// ad ids, ...) — everywhere except a shipped Product build.
  static const bool isShowTestOption = isClaude || isAlpha || isDev;
}
