import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/avatar_controller.dart';
import 'package:smartdrinkai/models/ui_models/avatar_option.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:smartdrinkai/values/route_name.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TodayHeader extends StatelessWidget {
  const TodayHeader({super.key});

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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ngày ${now.day} Thg ${now.month}, ${now.year}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ob.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: ob.textPrimary,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Hôm nay hãy uống đủ nước nhé! 💧',
                  style: TextStyle(
                    fontSize: 13,
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
          _CircleButton(
            onTap: () => Get.toNamed(RouteName.avatarSelection),
            child: const _AvatarThumb(),
          ),
        ],
      ),
    );
  }
}

/// Avatar shown inside the header button.
///
/// The figure artwork is still being produced, so this falls back to a person
/// glyph whenever the selected option has no asset yet.
class _AvatarThumb extends StatelessWidget {
  const _AvatarThumb();

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final controller = Get.find<AvatarController>();

    return Obx(() {
      final asset = AvatarOption.assetFor(controller.savedAvatarId.value);
      if (asset == null) {
        return Icon(Icons.person_rounded, color: ob.textPrimary, size: 22);
      }
      return ClipOval(child: Image.asset(asset, fit: BoxFit.cover));
    });
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ob.bgOption,
          border: Border.all(color: ob.borderTabHistory, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
