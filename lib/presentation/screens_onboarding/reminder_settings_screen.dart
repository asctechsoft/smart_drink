import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/onboarding_controller.dart';
import 'package:smartdrinkai/presentation/common_components/custom_switch.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/presentation/common_components/water_wave_background.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:smartdrinkai/values/route_name.dart';
import 'package:get/get.dart';
import 'components/interval_picker_sheet.dart';
import 'components/sound_effect_picker_sheet.dart';
import 'notification_permission_screen.dart';

class OnboardingReminderSettingsScreen extends StatelessWidget {
  const OnboardingReminderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    final ob = OnboardingTheme.of(context);
    return WaterWaveBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Title centered
                AppText(
                  'reminders'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ob.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
                // Back button on the left
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AppIcon(
                    'assets/images/svg/ic_back_left.svg',
                    size: 24,
                    onClick: () => Get.back(),
                    tint: ob.textPrimary,
                    autoMirror: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: AppColumn(
            modifier: Modifier.padding(horizontal: 24),
            children: [
              AppColumn(
                children: [
                  _buildSettingRow(
                    context,
                    'interval'.tr,
                    Obx(() {
                      final mins = controller.intervalMinutes.value;
                      final h = mins ~/ 60;
                      final m = mins % 60;
                      return AppText(
                        '${h > 0 ? "$h ${h > 1 ? 'hours'.tr : 'hour'.tr} " : ""}${m > 0 ? "$m ${'min'.tr}" : ""}',
                        style: TextStyle(
                          color: ob.textActiveBottomNavBar,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    }),
                    onTap: () => IntervalPickerSheet.show(context, controller),
                  ),
                  AppSpacerH8,
                  Divider(height: 1, thickness: 1, color: ob.bgOnboarding),
                  AppSpacerH8,
                  _buildSettingRow(
                    context,
                    'sound_effect'.tr,
                    Obx(() {
                      final sounds = [
                        {
                          'name': 'golden_bell'.tr,
                          'file': 'dragon_studio_correct',
                        },
                        {
                          'name': 'dragon_bloom'.tr,
                          'file': 'dragon_studio_notification_sound_effect',
                        },
                        {
                          'name': 'sparkle_pop'.tr,
                          'file': 'universfield_new_notification',
                        },
                        {
                          'name': 'modern_chime'.tr,
                          'file': 'universfield_notification',
                        },
                        {
                          'name': 'system_soft'.tr,
                          'file': 'universfield_system_notification',
                        },
                      ];
                      final currentFile = controller.soundEffect.value;
                      final soundName = sounds.firstWhere(
                        (s) => s['file'] == currentFile,
                        orElse: () => {'name': currentFile},
                      )['name']!;
                      return AppText(
                        soundName,
                        style: TextStyle(
                          color: ob.textActiveBottomNavBar,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    }),
                    onTap: () =>
                        SoundEffectPickerSheet.show(context, controller),
                  ),
                  AppSpacerH8,
                  Divider(height: 1, thickness: 1, color: ob.bgOnboarding),
                  AppSpacerH8,
                  Obx(
                    () => ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: AppText(
                        'vibrate'.tr,
                        style: TextStyle(
                          color: ob.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: CustomSwitch(
                        value: controller.vibrate.value,
                        activeColor: ob.switchActive,
                        trackColor: ob.switchTrack,
                        onChanged: (v) => controller.vibrate.value = v,
                      ),
                      onTap: () {
                        controller.vibrate.value = !controller.vibrate.value;
                      },
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: PrimaryButton(
                  text: 'next'.tr,
                  useGradient: true,
                  width: double.infinity,
                  onPressed: () {
                    showNotificationPermissionDialog(
                      context,
                      onComplete: () {
                        Get.toNamed(RouteName.onboardingDailyGoal);
                      },
                    );
                  },
                ),
              ),
              AppSpacerH20,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow(
    BuildContext context,
    String title,
    Widget trailing, {
    VoidCallback? onTap,
  }) {
    final ob = OnboardingTheme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: AppText(
        title,
        style: TextStyle(
          color: ob.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          trailing,
          if (onTap != null) ...[
            const SizedBox(width: 8),
            AppIcon('assets/images/svg/ic_edit.svg', size: 18, tint: ob.accent),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}

