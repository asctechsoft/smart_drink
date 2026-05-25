import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/reminder_controller.dart';
import 'package:smartdrinkai/models/ui_models/reminder_mode.dart';
import 'package:smartdrinkai/presentation/common_components/bottom_safe_area.dart';
import 'package:smartdrinkai/presentation/common_components/custom_switch.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';

import 'components/repeat_reminder_section.dart';
import 'components/sound_effect_section.dart';
import 'components/standard_mode_content.dart';
import 'components/interval_mode_content.dart';
import 'components/custom_mode_content.dart';

// ─── Styling constants ───────────────────────────────────────────────────────

class ReminderSettingsPage extends StatelessWidget {
  const ReminderSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReminderController>();
    final ob = OnboardingTheme.of(context);
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
          leading: IconButton(
            icon: AppIcon(
              'assets/images/svg/ic_back_left.svg',
              size: 24,
              tint: ob.textPrimary,
              autoMirror: true,
            ),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          title: AppText(
            'reminders'.tr,
            style: TextStyle(
              color: ob.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Obx(() {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              // Enable Reminder toggle
              _buildSettingRow(
                title: 'enable_reminder'.tr,
                trailing: _buildSwitch(
                  value: controller.enabled.value,
                  onChanged: (v) {
                    controller.enabled.value = v;
                    controller.saveSettings();
                  },
                  context: context,
                ),
                context: context,
                onTap: () {
                  controller.enabled.value = !controller.enabled.value;
                  controller.saveSettings();
                },
              ),
              if (controller.enabled.value) ...[
                _buildDivider(context),
                RepeatReminderSection(controller: controller),
                _buildDivider(context),
                SoundEffectSection(controller: controller),
                _buildDivider(context),
                _ModeSection(
                  title: 'standard_mode'.tr,
                  subtitle: 'based_on_your_sleep_and_meal_schedule'.tr,
                  isActive: controller.mode.value == ReminderMode.standard,
                  onToggle: (v) {
                    controller.setMode(
                      v ? ReminderMode.standard : ReminderMode.interval,
                    );
                  },
                  child: controller.mode.value == ReminderMode.standard
                      ? StandardModeContent(controller: controller)
                      : null,
                ),
                _buildDivider(context),
                _ModeSection(
                  title: 'interval_mode'.tr,
                  subtitle: 'remind_you_at_fixed_intervals'.tr,
                  isActive: controller.mode.value == ReminderMode.interval,
                  onToggle: (v) {
                    controller.setMode(
                      v ? ReminderMode.interval : ReminderMode.standard,
                    );
                  },
                  child: controller.mode.value == ReminderMode.interval
                      ? IntervalModeContent(controller: controller)
                      : null,
                ),
                _buildDivider(context),
                _ModeSection(
                  title: 'custom_mode'.tr,
                  subtitle: 'customize_all_reminders_by_yourself'.tr,
                  isActive: controller.mode.value == ReminderMode.custom,
                  onToggle: (v) {
                    controller.setMode(
                      v ? ReminderMode.custom : ReminderMode.standard,
                    );
                  },
                  child: controller.mode.value == ReminderMode.custom
                      ? CustomModeContent(controller: controller)
                      : null,
                ),
              ],
              BottomSafeArea(),
            ],
          );
        }),
      ),
    );
  }
}

Widget _buildSettingRow({
  required String title,
  String? subtitle,
  Widget? trailing,
  VoidCallback? onTap,
  required BuildContext context,
}) {
  final ob = OnboardingTheme.of(context);
  return InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: onTap,
    child: AppRow(
      modifier: Modifier.padding(vertical: 14, horizontal: 12),
      children: [
        Expanded(
          child: AppColumn(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ob.textPrimary,
                ),
              ),
              if (subtitle != null)
                AppText(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: ob.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    ),
  );
}

Widget _buildSwitch({
  required bool value,
  required ValueChanged<bool> onChanged,
  required BuildContext context,
}) {
  final ob = OnboardingTheme.of(context);
  return CustomSwitch(
    value: value,
    onChanged: onChanged,
    activeColor: ob.switchActive,
    trackColor: ob.switchTrack,
  );
}

Widget _buildDivider(BuildContext context) {
  final ob = OnboardingTheme.of(context);
  return Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 8),
    child: Divider(color: ob.bgOnboarding, height: 1),
  );
}

// // ─── Mode Section (wrapper for each mode) ────────────────────────────────────

class _ModeSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isActive;
  final ValueChanged<bool> onToggle;
  final Widget? child;

  const _ModeSection({
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.onToggle,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return AppColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppRow(
          modifier: Modifier.padding(vertical: 10, horizontal: 12),
          children: [
            Expanded(
              child: AppColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    style: TextStyle(
                      color: ob.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const AppSpacerH(2),
                  AppText(
                    subtitle,
                    style: TextStyle(color: ob.textSubtitle, fontSize: 13),
                  ),
                ],
              ),
            ),
            _buildSwitch(
              value: isActive,
              onChanged: onToggle,
              context: context,
            ),
          ],
        ),
        if (child != null) child!,
      ],
    );
  }
}

// // ─── Interval Mode Content ───────────────────────────────────────────────────
