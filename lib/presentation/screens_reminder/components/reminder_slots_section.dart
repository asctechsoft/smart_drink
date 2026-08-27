import 'package:dsp_base/app_material.dart';
import 'package:get/get.dart';
import 'package:waternudge/controller/reminder_controller.dart';
import 'package:waternudge/models/data_models/reminder_schedule.dart';
import 'package:waternudge/presentation/common_components/custom_switch.dart';
import 'package:waternudge/presentation/screens_reminder/components/standard_mode_content.dart'
    show showWheelTimePicker;
import 'package:waternudge/values/onboarding_theme.dart';

/// "Các mốc nhắc" — the labelled per-slot reminder list. Moved out of the
/// Standard tab so it can live under the Custom tab. Operates on the
/// standard-labelled schedules (the ones the native scheduler fires).
class ReminderSlotsSection extends StatelessWidget {
  final ReminderController controller;
  const ReminderSlotsSection({super.key, required this.controller});

  ReminderController get ctrl => controller;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Các mốc nhắc',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: ob.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Nhấn vào mốc để chỉnh giờ',
          style: TextStyle(fontSize: 11, color: ob.textSecondary),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final items = ctrl.standardSchedules;
          final labels = ReminderController.standardLabels;
          final defaultTimes = ReminderController.standardTimes;
          return Column(
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                _slotRow(
                  context,
                  labels[i],
                  items.firstWhereOrNull((s) => s.label == labels[i]),
                  defaultTimes[i],
                ),
                if (i < labels.length - 1) const SizedBox(height: 8),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _slotRow(
    BuildContext context,
    String label,
    ReminderSchedule? schedule,
    String fallback,
  ) {
    final ob = OnboardingTheme.of(context);
    final time = schedule?.time ?? fallback;
    final enabled = schedule?.enabled ?? true;
    final hour = int.tryParse(time.split(':').first) ?? 8;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Row(
        children: [
          _iconBox(_slotIcon(hour)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label.tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: enabled ? ob.textPrimary : ob.textSecondary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => showWheelTimePicker(
              context,
              title: label.tr,
              initialTime: time,
              onSave: (newTime) {
                if (schedule != null) {
                  ctrl.updateSchedule(schedule.copyWith(time: newTime));
                } else {
                  ctrl.addSchedule(
                    ReminderSchedule(
                      mode: 'standard',
                      time: newTime,
                      label: label,
                    ),
                  );
                }
              },
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: ob.textActiveBottomNavBar.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                ctrl.formatDisplayTime(time),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ob.textActiveBottomNavBar,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CustomSwitch(
            value: enabled,
            onChanged: (v) {
              if (schedule != null) {
                ctrl.updateSchedule(schedule.copyWith(enabled: v));
              } else {
                ctrl.addSchedule(
                  ReminderSchedule(
                    mode: 'standard',
                    time: fallback,
                    label: label,
                    enabled: v,
                  ),
                );
              }
            },
            activeColor: ob.switchActive,
            trackColor: ob.switchTrack,
          ),
        ],
      ),
    );
  }

  static const Color _iconTint = Color(0xFF96D2A8);

  Widget _iconBox(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
      ),
      child: Center(child: Icon(icon, size: 24, color: _iconTint)),
    );
  }

  IconData _slotIcon(int hour) {
    if (hour < 10) return Icons.wb_sunny_outlined;
    if (hour < 13) return Icons.wb_sunny_rounded;
    if (hour < 17) return Icons.cloud_outlined;
    if (hour < 20) return Icons.nights_stay_outlined;
    return Icons.bedtime_outlined;
  }
}
