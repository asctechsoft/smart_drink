import 'package:waternudge/presentation/common_components/bubble_celebration.dart';
import 'package:waternudge/values/onboarding_theme.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TodayHeader extends StatelessWidget {
  const TodayHeader({super.key});

  /// Greeting keyed to the current time of day.
  String _greeting(int hour) {
    if (hour < 11) return 'greeting_morning'.tr;
    if (hour < 13) return 'greeting_noon'.tr;
    if (hour < 18) return 'greeting_afternoon'.tr;
    return 'greeting_evening'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: date + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _greeting(now.hour),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ob.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'today_drink_water_hint'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: ob.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // Right: mascot icon.
          const _MascotIcon(),
        ],
      ),
    );
  }
}

class _MascotIcon extends StatefulWidget {
  const _MascotIcon();

  @override
  State<_MascotIcon> createState() => _MascotIconState();
}

class _MascotIconState extends State<_MascotIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.88,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(BuildContext context) {
    playBubbleSound();
    showBubbleCelebration(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTap(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(5),
        child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) =>
              Transform.scale(scale: _scale.value, child: child),
          child: Image.asset(
            'assets/images/png/img_mascot.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
