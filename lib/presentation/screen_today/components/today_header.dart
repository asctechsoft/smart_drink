import 'package:dsp_base/app_material.dart';
import 'package:waternudge/values/onboarding_theme.dart';
import 'package:waternudge/values/route_name.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TodayHeader extends StatelessWidget {
  const TodayHeader({super.key, this.chatKey});

  /// Optional key so a coach-mark can spotlight the chat shortcut button.
  final GlobalKey? chatKey;

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

          // Right: chat bot shortcut only.
          KeyedSubtree(
            key: chatKey,
            child: _CircleButton(
              onTap: () => Get.toNamed(RouteName.chatBot),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  'assets/images/png/ic_chat_bot.png',
                  fit: BoxFit.contain,
                ),
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
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
