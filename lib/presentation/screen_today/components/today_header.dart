import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:smartdrinkai/controller/today_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TodayHeader extends StatelessWidget {
  const TodayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final controller = Get.find<TodayController>();
    final now = DateTime.now();

    return AppRow(
      modifier: Modifier.padding(horizontal: 16, vertical: 12),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: AppText(
            'Ngày ${now.day} Thg ${now.month}, ${now.year}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ob.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Obx(() {
            final intake = controller.currentIntakeMl.value;
            final goal = controller.adjustedGoal;
            final remaining = (goal - intake) > 0 ? (goal - intake) : 0;

            return AppColumn(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppRow(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.check_circle,
                        size: 14,
                        color: ob.textPrimary.withOpacity(0.9),
                      ),
                    ),
                    AppSpacerW4,
                    Expanded(
                      child: AppText(
                        'Tổng lượng nước hấp thụ\nhôm nay',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          color: ob.textPrimary.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacerH4,
                AppText(
                  '$intake ml',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF67B5E2),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF67B5E2),
                  ),
                ),
                AppSpacerH4,
                AppText(
                  'Mục tiêu hôm nay: $goal ml',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ob.textPrimary,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
