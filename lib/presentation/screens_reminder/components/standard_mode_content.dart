import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/reminder_controller.dart';
import 'package:smartdrinkai/models/data_models/reminder_schedule.dart';
import 'package:smartdrinkai/presentation/common_components/custom_switch.dart';
import 'package:smartdrinkai/presentation/common_components/primary_bottom_sheet.dart';
import 'package:smartdrinkai/presentation/common_components/wheel_time_picker.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';

class StandardModeContent extends StatelessWidget {
  final ReminderController controller;
  const StandardModeContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Obx(() {
      final items = controller.standardSchedules;
      final labels = ReminderController.standardLabels;
      final defaultTimes = ReminderController.standardTimes;
      return AppColumn(
        modifier: Modifier.background(
          color: ob.bgReminderOption,
          radius: 16,
        ).padding(all: 12),
        children: List.generate(labels.length, (i) {
          final schedule = items.firstWhereOrNull((s) => s.label == labels[i]);
          final time = schedule?.time ?? defaultTimes[i];
          final enabled = schedule?.enabled ?? true;

          return AppRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AppRow(
                  modifier: Modifier.appClickable(
                    onTap: () => showWheelTimePicker(
                      context,
                      title: (schedule?.label ?? labels[i]).tr,
                      initialTime: time,
                      onSave: (newTime) {
                        if (schedule != null) {
                          controller.updateSchedule(
                            schedule.copyWith(time: newTime),
                          );
                        } else {
                          controller.addSchedule(
                            ReminderSchedule(
                              mode: 'standard',
                              time: newTime,
                              label: labels[i],
                            ),
                          );
                        }
                      },
                    ),
                    radius: 16,
                  ).padding(horizontal: 12, vertical: 16),
                  children: [
                    Expanded(
                      child: AppText(
                        labels[i].tr,
                        style: TextStyle(
                          color: ob.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    AppText(
                      controller.formatDisplayTime(time).tr,
                      style: TextStyle(
                        color: ob.textActiveBottomNavBar,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const AppSpacerW(8),
              _buildSwitch(
                context: context,
                value: enabled,
                onChanged: (v) {
                  if (schedule != null) {
                    controller.updateSchedule(schedule.copyWith(enabled: v));
                  } else {
                    controller.addSchedule(
                      ReminderSchedule(
                        mode: 'standard',
                        time: defaultTimes[i],
                        label: labels[i],
                        enabled: v,
                      ),
                    );
                  }
                },
              ),
            ],
          );
        }),
      );
    });
  }

  Widget _buildSwitch({
    required BuildContext context,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final ob = OnboardingTheme.of(context);
    return CustomSwitch(
      value: value,
      onChanged: onChanged,
      activeColor: ob.switchActive,
      trackColor: ob.switchTrack,
    );
  }
}

void showWheelTimePicker(
  BuildContext context, {
  required String title,
  required String initialTime,
  required ValueChanged<String> onSave,
}) {
  String selectedTime = initialTime;
  PrimaryBottomSheet.show(
    context: context,
    title: title,
    buttonText: 'Save',
    onButtonPressed: () {
      Navigator.pop(context);
      onSave(selectedTime);
    },
    content: WheelTimePicker(
      initialTime: initialTime,
      onChanged: (t) => selectedTime = t,
    ),
  );
}

