import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/controller/today_controller.dart';
import 'package:smartdrinkai/presentation/common_components/progress_ring.dart';
import 'package:smartdrinkai/presentation/common_components/water_wave_background.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:smartdrinkai/utils/unit_converter.dart';
import 'package:get/get.dart';
import 'package:smartdrinkai/presentation/screen_today/components/today_header.dart';
import 'package:smartdrinkai/presentation/screen_today/components/add_drink_button.dart';
import 'package:smartdrinkai/presentation/screen_today/components/today_quick_actions.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodayController>();
    return WaterWaveBackground(
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
                      AppSpacerH12,
                      // Reminder pill
                      Obx(() {
                        debugPrint(
                          'reminderCountdown: ${controller.reminderCountdown.value}',
                        );
                        return _buildReminderPill(controller, context);
                      }),
                      AppSpacerH24,
                      Obx(
                        () => ProgressRing(
                          size: 300,
                          progress: controller.progress,
                          currentMl: controller.currentIntakeMl.value,
                          goalMl: controller.adjustedGoal,
                          volumeUnit: Get.find<SettingsController>()
                              .volumeUnit
                              .value,
                          textScale: 1, // Scale text theo size
                        ),
                      ),
                      AppSpacerH(8),
                      Obx(() => _buildGoalStatus(controller, context)),

                      AppSpacerH24,
                      // Quick action buttons
                      const TodayQuickActions(),
                      AppSpacerH24,

                      // Add Drink button
                      const AddDrinkButton(),
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

  Widget _buildReminderPill(TodayController controller, BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return AppColumn(
      children: [
        AppRow(
          mainAxisSize: MainAxisSize.min,
          modifier: Modifier.background(
            color: ob.bgOption,
            radius: 100,
          ).padding(horizontal: 16, vertical: 8),
          children: [
            AppIcon(
              'assets/images/svg/ic_time_alarm.svg',
              size: 20,
              tint: ob.textReminderIcon,
            ),
            AppSpacerW8,
            AppText(
              controller.nextReminderTime.value.isEmpty
                  ? 'no_reminder_set'.tr
                  : 'next_reminder'.trParams({
                      "args1": UnitConverter.formatTime(
                        controller.nextReminderTime.value,
                        Get.find<SettingsController>().timeFormat.value,
                      ),
                    }),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ob.textReminderIcon,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
        // if (controller.reminderCountdown.value.isNotEmpty)
        //   AppText(
        //     '(${controller.reminderCountdown.value})',
        //     style: TextStyle(
        //       fontSize: 12,
        //       fontWeight: FontWeight.w400,
        //       color: ob.textrReminderCountdown,
        //       letterSpacing: 0.6,
        //     ),
        //     modifier: Modifier.padding(top: 4),
        //   ),
      ],
    );
  }
}

