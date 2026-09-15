import 'dart:math' as math;

import 'package:dsp_base/app_material.dart';
import 'package:waternudge/configs/pref_const.dart';
import 'package:waternudge/controller/user_profile_controller.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';
import 'package:waternudge/values/app_colors.dart';
import 'package:waternudge/values/route_name.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait for both the minimum splash duration and profile loading to finish
    final profileCtrl = Get.find<UserProfileController>();
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      _waitForProfile(profileCtrl),
    ]);
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final onboarded = prefs.getBool(PrefConst.onboardingCompleted) ?? false;
    if (onboarded) {
      Get.offAllNamed(RouteName.home);
    } else {
      Get.offAllNamed(RouteName.onboardingLanguage);
    }
  }

  Future<void> _waitForProfile(UserProfileController ctrl) async {
    // Wait until profile loading is done (max 5 seconds)
    final deadline = DateTime.now().add(const Duration(seconds: 20));
    while (ctrl.isLoading.value && DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 1000));
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Bubbles rise gently behind everything, the same motif as the
            // daily-goal celebration on the Today screen.
            const Positioned.fill(
              child: IgnorePointer(child: _SplashBubbles()),
            ),
            Positioned.fill(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 5),
                    AppIcon('assets/images/png/logo_app_v3.png', size: 104),
                    AppSpacerH16,
                    AppText(
                      'AquaMind',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppText(
                      'Theo dõi nước uống mỗi ngày',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                    const Spacer(flex: 5),
                    const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(
                          AppColors.btnCyanEnd,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppText(
                      'Đang khởi động...',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Rising-bubble background ───────────────────────────────────────────────────
// A looping field of translucent bubbles drifting up the screen. Unlike the
// one-shot celebration, this repeats forever, so it can play under the splash
// for as long as the app takes to load.
class _SplashBubbles extends StatefulWidget {
  const _SplashBubbles();

  @override
  State<_SplashBubbles> createState() => _SplashBubblesState();
}

class _SplashBubblesState extends State<_SplashBubbles>
    with SingleTickerProviderStateMixin {
  static const _count = 20;

  static const _palette = [
    AppColors.primary500Dark,
    AppColors.btnCyanEnd,
    AppColors.accentTeal,
    AppColors.basic500,
    AppColors.onboardingButtonStart,
  ];

  late final AnimationController _controller;
  late final List<_SplashBubble> _bubbles;

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    _bubbles = List.generate(_count, (i) {
      // Even columns + jitter so bubbles cover the width instead of clumping.
      final column = (i + 0.5) / _count;
      return _SplashBubble(
        x: (column + (random.nextDouble() - 0.5) * 0.9 / _count).clamp(
          0.02,
          0.98,
        ),
        radius: 4 + random.nextDouble() * 13,
        // Loops-per-cycle: some bubbles rise faster than others.
        speed: 0.55 + random.nextDouble() * 0.7,
        phase: random.nextDouble(),
        sway: 6 + random.nextDouble() * 18,
        swayCycles: 0.5 + random.nextDouble() * 1.3,
        color: _palette[random.nextInt(_palette.length)],
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _SplashBubblePainter(progress: _controller, bubbles: _bubbles),
      ),
    );
  }
}

class _SplashBubble {
  const _SplashBubble({
    required this.x,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.sway,
    required this.swayCycles,
    required this.color,
  });

  final double x;
  final double radius;
  final double speed;
  final double phase;
  final double sway;
  final double swayCycles;
  final Color color;
}

class _SplashBubblePainter extends CustomPainter {
  _SplashBubblePainter({required this.progress, required this.bubbles})
    : super(repaint: progress);

  final Animation<double> progress;
  final List<_SplashBubble> bubbles;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;

    for (final bubble in bubbles) {
      // Each bubble loops through 0→1 at its own speed and offset.
      final local = (t * bubble.speed + bubble.phase) % 1.0;

      // Start a diameter below the bottom, finish a diameter above the top, so
      // bubbles slide in and out of view instead of popping on and off.
      final span = size.height + bubble.radius * 4;
      final center = Offset(
        size.width * bubble.x +
            math.sin(local * bubble.swayCycles * 2 * math.pi) * bubble.sway,
        size.height + bubble.radius * 2 - local * span,
      );

      // Fade in over the first sliver, hold, fade out near the top.
      final opacity = local < 0.12
          ? local / 0.12
          : local > 0.82
          ? (1 - local) / 0.18
          : 1.0;

      _paintBubble(canvas, bubble, center, opacity.clamp(0.0, 1.0));
    }
  }

  /// Soft translucent body, a bright rim, and one specular highlight — the same
  /// look as the celebration bubbles.
  void _paintBubble(
    Canvas canvas,
    _SplashBubble bubble,
    Offset center,
    double opacity,
  ) {
    final radius = bubble.radius;

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = bubble.color.withValues(alpha: 0.12 * opacity),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = bubble.color.withValues(alpha: 0.5 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, radius * 0.12),
    );

    if (radius > 7) {
      canvas.drawCircle(
        center.translate(-radius * 0.32, -radius * 0.34),
        radius * 0.2,
        Paint()..color = AppColors.basic500.withValues(alpha: 0.5 * opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_SplashBubblePainter oldDelegate) => false;
}
