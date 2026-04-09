import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/history_controller.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';

class HistoryPeriodSelector extends StatelessWidget {
  final HistoryController controller;
  final VoidCallback onTitleTap;

  const HistoryPeriodSelector({
    super.key,
    required this.controller,
    required this.onTitleTap,
  });

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return AppColumn(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppRow(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppIcon(
              'assets/images/svg/ic_back_left.svg',
              size: 24,
              onClick: controller.previousPeriod,
              tint: ob.textPrimary,
              autoMirror: true,
              modifier: Modifier.width(48),
            ),
            Expanded(
              child: Center(
                child: Obx(() {
                  final isDay =
                      controller.viewMode.value == HistoryViewMode.day;
                  final color = isDay
                      ? ob.textActiveBottomNavBar
                      : ob.textPrimary;
                  final decoration = isDay
                      ? TextDecoration.underline
                      : TextDecoration.none;

                  return AppRow(
                    modifier: Modifier.appClickable(
                      onTap: onTitleTap,
                      radius: 16,
                    ).padding(horizontal: 12, vertical: 6),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isDay) ...[
                        AppIcon(
                          'assets/images/svg/ic_calendar.svg',
                          size: 16,
                          tint: color,
                        ),
                        const AppSpacerW(8),
                      ],
                      AppText(
                        controller.periodLabel.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: color,
                          decoration: decoration,
                          decorationColor: color,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            Obx(() {
              final canGoNext = controller.canGoNext;
              return AppIcon(
                'assets/images/svg/ic_back_right.svg',
                size: 24,
                tint: ob.textPrimary,
                autoMirror: true,
                onClick: canGoNext ? controller.nextPeriod : null,
                modifier: Modifier.width(48).alpha(canGoNext ? 1.0 : 0.0),
              );
            }),
          ],
        ),
      ],
    );
  }
}

