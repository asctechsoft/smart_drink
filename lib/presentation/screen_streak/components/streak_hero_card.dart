import 'package:dsp_base/app_material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternudge/controller/streak_controller.dart';
import 'package:waternudge/values/app_colors.dart';
import 'package:waternudge/values/onboarding_theme.dart';

/// Big card at the top: flame artwork, the streak count and the next milestone.
class StreakHeroCard extends StatelessWidget {
  const StreakHeroCard({super.key, required this.controller});

  final StreakController controller;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: ob.cardGlowShadow,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/webp/img_drink_streak.webp',
                width: 110,
                height: 110,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${controller.currentStreak.value}',
                        style: TextStyle(
                          fontSize: 44,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary500Dark,
                        ),
                      ),
                      Text(
                        'day_streak'.tr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: ob.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.currentStreak.value > 0
                            ? 'streak_keep_it_up'.tr
                            : 'streak_start_today'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: ob.textPrimary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
