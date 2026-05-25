import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/controller/today_controller.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/presentation/common_components/water_cup_progress.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';

import 'package:get/get.dart';
import 'package:smartdrinkai/presentation/screen_today/components/today_header.dart';
import 'package:smartdrinkai/presentation/screen_today/components/drink_action_bar.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodayController>();
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 10,
          ),
          child: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header
                      TodayHeader(),
                      AppSpacerH24,

                      // Goal Volume Text
                      Obx(
                        () => WaterCupProgress(
                          progress: controller.progress,
                          currentMl: controller.currentIntakeMl.value,
                          goalMl: controller.adjustedGoal,
                          volumeUnit:
                              Get.find<SettingsController>().volumeUnit.value,
                          width: 300,
                          height: 300,
                        ),
                      ),
                      Obx(() => _buildGoalStatus(controller, context)),
                      AppSpacerH36,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Obx(
                          () => _buildStatusCards(controller, context),
                        ),
                      ),

                      AppSpacerH24,
                      // Drink action bar: cup size | +amount | drink type
                      const DrinkActionBar(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCards(TodayController controller, BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final currentMl = controller.currentIntakeMl.value;
    final goalMl = controller.adjustedGoal;
    final remaining = (goalMl - currentMl) > 0 ? (goalMl - currentMl) : 0;

    final lastDrink = controller.todayRecords.isNotEmpty
        ? controller.todayRecords.last
        : null;
    String lastTimeStr = '--:--';
    if (lastDrink != null) {
      final amPm = lastDrink.timestamp.hour >= 12 ? 'chiều' : 'sáng';
      int hour12 = lastDrink.timestamp.hour % 12;
      if (hour12 == 0) hour12 = 12;
      final hour12Str = hour12.toString().padLeft(2, '0');
      final minStr = lastDrink.timestamp.minute.toString().padLeft(2, '0');
      lastTimeStr = '$hour12Str:$minStr $amPm';
    }

    return AppRow(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: ob.bgOption,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ob.borderTabHistory, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'Còn lại',
                  style: TextStyle(
                    fontSize: 14,
                    color: ob.textPrimary.withOpacity(0.6),
                  ),
                ),
                AppSpacerH4,
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$remaining ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF67B5E2),
                          fontFamily: 'Inter',
                        ),
                      ),
                      TextSpan(
                        text: 'ml',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ob.textPrimary.withOpacity(0.6),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        AppSpacerW16,
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: ob.bgOption,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ob.borderTabHistory, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'Lần cuối',
                  style: TextStyle(
                    fontSize: 14,
                    color: ob.textPrimary.withOpacity(0.6),
                  ),
                ),
                AppSpacerH4,
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: lastDrink != null
                            ? '${lastTimeStr.split(' ')[0]} '
                            : '--:-- ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9CCC65),
                          fontFamily: 'Inter',
                        ),
                      ),
                      TextSpan(
                        text: lastDrink != null
                            ? lastTimeStr.split(' ')[1]
                            : '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ob.textPrimary.withOpacity(0.6),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalStatus(TodayController controller, BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final currentMl = controller.currentIntakeMl.value;
    final goalMl = controller.adjustedGoal;

    if (currentMl < goalMl) return const SizedBox.shrink();
    final bool isExceeded = currentMl > goalMl;

    return AppRow(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppText(
          isExceeded ? 'exceeded_your_goal'.tr : 'goal_completed'.tr,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ob.textPrimary,
            letterSpacing: 0.9,
          ),
        ),
        if (isExceeded) ...[
          AppSpacerW2,
          AppText(
            '${(((currentMl / goalMl) - 1.0) * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ob.textReminderIcon,
              letterSpacing: 0.9,
            ),
          ),
        ],
      ],
    );
  }
}
