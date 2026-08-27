import 'package:dsp_base/app_material.dart';
import 'package:waternudge/values/onboarding_theme.dart';
import 'package:waternudge/values/route_name.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TodayHeader extends StatelessWidget {
  const TodayHeader({super.key});

  /// Greeting keyed to the current time of day.
  String _greeting(int hour) {
    if (hour < 11) return 'Chào buổi sáng ☀️';
    if (hour < 13) return 'Chào buổi trưa 🌤️';
    if (hour < 18) return 'Chào buổi chiều ⛅';
    return 'Chào buổi tối 🌙';
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
                  'Hôm nay hãy uống đủ nước nhé! 💧',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: ob.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // Right: streak + avatar shortcuts
          _CircleButton(
            onTap: () => Get.toNamed(RouteName.streak),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Image.asset(
                'assets/images/webp/img_drink_streak.webp',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Chat bot shortcut (replaced the avatar button).
          _CircleButton(
            onTap: () => Get.toNamed(RouteName.chatBot),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                'assets/images/png/ic_chat_bot.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
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
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
