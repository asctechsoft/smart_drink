import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/reminder_controller.dart';
import 'package:smartdrinkai/models/data_models/reminder_schedule.dart';
import 'package:smartdrinkai/presentation/common_components/primary_bottom_sheet.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/presentation/common_components/wheel_time_picker.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:smartdrinkai/utils/toast_utils.dart';
import 'package:get/get.dart';

class CustomModeContent extends StatelessWidget {
  final ReminderController controller;
  const CustomModeContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Obx(() {
      final items = controller.customSchedules.toList()
        ..sort((a, b) => a.time.compareTo(b.time));
      return AppColumn(
        modifier: Modifier.background(
          color: items.isEmpty ? Colors.transparent : ob.bgReminderOption,
          radius: 16,
        ).padding(all: 12),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items.isNotEmpty) ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.5,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final s = items[i];
                return AppBoxCentered(
                  modifier: Modifier.background(color: ob.bgToggle, radius: 8)
                      .appClickable(
                        onTap: () =>
                            _showEditTimerSheet(context, controller, s),
                        radius: 8,
                      ),
                  children: [
                    Center(
                      child: AppText(
                        controller.formatDisplayTime(s.time),
                        style: TextStyle(
                          color: s.enabled ? ob.textPrimary : ob.textSubtitle,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
          AppSpacerH12,
          // Add button
          AppBoxCentered(
            modifier: Modifier.background(color: ob.accent, radius: 8)
                .width(92)
                .height(38)
                .appClickable(
                  onTap: () => _showAddTimerSheet(context, controller),
                  radius: 8,
                ),
            children: [
              Center(
                child: AppIcon(
                  'assets/images/svg/ic_alarm_add.svg',
                  size: 24,
                  tint: Colors.white,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

void _showEditTimerSheet(
  BuildContext context,
  ReminderController controller,
  ReminderSchedule schedule,
) {
  String time = schedule.time;
  PrimaryBottomSheet.show(
    context: context,
    title: 'edit_timer'.tr,
    showSubmitButton: false,
    content: AppColumn(
      children: [
        WheelTimePicker(initialTime: time, onChanged: (t) => time = t),
        const AppSpacerH(24),
        AppRow(
          children: [
            // Remove button
            Expanded(
              child: PrimaryButton(
                text: 'remove'.tr,
                solidColor: const Color(0xFFFD7469),
                onPressed: schedule.label == 'custom_1'
                    ? () {
                        ToastUtils.showToast(
                          context,
                          'This record cannot be removed',
                        );
                      }
                    : () {
                        if (schedule.id != null) {
                          controller.removeSchedule(schedule.id!);
                        }
                        Navigator.pop(context);
                      },
                height: 44,
              ),
            ),
            const AppSpacerW(12),
            // Save button
            Expanded(
              child: PrimaryButton(
                text: 'save'.tr,
                useGradient: true,
                onPressed: () {
                  final duplicate = controller.customSchedules.any(
                    (s) => s.time == time && s.id != schedule.id,
                  );
                  if (duplicate) {
                    ToastUtils.showToast(
                      context,
                      'a_reminder_at'.trParams({
                        'args1': controller.formatDisplayTime(time),
                      }),
                    );
                    return;
                  }
                  controller.updateSchedule(schedule.copyWith(time: time));
                  Navigator.pop(context);
                },
                height: 44,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

void _showAddTimerSheet(BuildContext context, ReminderController controller) {
  String time = '08:00';
  PrimaryBottomSheet.show(
    context: context,
    title: 'add_timer'.tr,
    buttonText: 'add'.tr,
    onButtonPressed: () {
      final duplicate = controller.customSchedules.any((s) => s.time == time);
      if (duplicate) {
        ToastUtils.showToast(
          context,
          'a_reminder_at'.trParams({
            'args1': controller.formatDisplayTime(time),
          }),
        );
        return;
      }
      controller.addSchedule(ReminderSchedule(mode: 'custom', time: time));
      Navigator.pop(context);
    },
    content: WheelTimePicker(initialTime: time, onChanged: (t) => time = t),
  );
}

