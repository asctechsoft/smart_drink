import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternudge/controller/reminder_controller.dart';
import 'package:waternudge/models/data_models/reminder_schedule.dart';
import 'package:waternudge/presentation/common_components/custom_switch.dart';
import 'package:waternudge/presentation/common_components/primary_bottom_sheet.dart';
import 'package:waternudge/presentation/common_components/wheel_time_picker.dart';
import 'package:waternudge/utils/toast_utils.dart';
import 'package:waternudge/values/onboarding_theme.dart';

/// The "Tùy chỉnh" (`ReminderMode.standard`) form of the reminder screen:
/// master switch + a free-form list of exact reminder times the user adds
/// themselves (no fixed slots, no time range — whichever time is picked,
/// that's when it notifies; two entries can't share the same time).
class StandardModeContent extends StatefulWidget {
  final ReminderController controller;
  const StandardModeContent({super.key, required this.controller});

  @override
  State<StandardModeContent> createState() => _StandardModeContentState();
}

class _StandardModeContentState extends State<StandardModeContent> {
  ReminderController get ctrl => widget.controller;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Everything below is greyed out + non-interactive while the master
        // reminder switch is off (the master toggle now lives in Settings).
        Obx(
          () => DisabledOverlay(
            disabled: !ctrl.enabled.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'reminder_custom_times_title'.tr,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ob.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'reminder_custom_times_subtitle'.tr,
                  style: TextStyle(fontSize: 11, color: ob.textSecondary),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final items = List<ReminderSchedule>.from(
                    ctrl.customSchedules,
                  )..sort((a, b) => a.time.compareTo(b.time));
                  return Column(
                    children: [
                      for (final schedule in items) ...[
                        _slotRow(schedule),
                        const SizedBox(height: 8),
                      ],
                      _addRow(items),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Whether [time] collides with an existing custom schedule other than
  /// [excludeId] (the one being edited, if any).
  bool _isDuplicate(List<ReminderSchedule> items, String time, int? excludeId) {
    return items.any((s) => s.id != excludeId && s.time == time);
  }

  Widget _slotRow(ReminderSchedule schedule) {
    final ob = OnboardingTheme.of(context);
    final time = schedule.time;
    final enabled = schedule.enabled;
    final hour = int.tryParse(time.split(':').first) ?? 8;

    void openTimePicker() {
      final items = ctrl.customSchedules;
      showWheelTimePicker(
        context,
        title: 'reminder_custom_times_title'.tr,
        initialTime: time,
        onSave: (newTime) {
          if (_isDuplicate(items, newTime, schedule.id)) {
            ToastUtils.showToast(context, 'reminder_time_duplicate'.tr);
            return;
          }
          ctrl.updateSchedule(schedule.copyWith(time: newTime));
        },
      );
    }

    return _card(
      onTap: openTimePicker,
      child: Row(
        children: [
          _iconCircle(_slotIcon(hour)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ctrl.formatDisplayTime(time),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: enabled ? ob.textPrimary : ob.textSecondary,
              ),
            ),
          ),
          CustomSwitch(
            value: enabled,
            onChanged: (v) =>
                ctrl.updateSchedule(schedule.copyWith(enabled: v)),
            activeColor: ob.switchActive,
            trackColor: ob.switchTrack,
          ),
          const SizedBox(width: 4),
          // Deeper in the hit-test path than the row's own InkWell, so it
          // wins the gesture arena — tapping it never also opens the picker.
          IconButton(
            onPressed: schedule.id == null
                ? null
                : () => ctrl.removeSchedule(schedule.id!),
            icon: Icon(Icons.close_rounded, size: 20, color: ob.textSecondary),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _addRow(List<ReminderSchedule> items) {
    final ob = OnboardingTheme.of(context);

    void addTime() {
      // Suggest the next free half-hour slot after the last existing entry
      // (or a sane default when the list is empty) so the picker doesn't
      // open pre-filled on a time that's already taken.
      var suggested = items.isEmpty ? '08:00' : items.last.time;
      while (_isDuplicate(items, suggested, null)) {
        final parts = suggested.split(':');
        var minute = (int.tryParse(parts[1]) ?? 0) + 30;
        var hour = int.tryParse(parts[0]) ?? 8;
        if (minute >= 60) {
          minute -= 60;
          hour = (hour + 1) % 24;
        }
        suggested =
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }

      showWheelTimePicker(
        context,
        title: 'reminder_custom_times_title'.tr,
        initialTime: suggested,
        onSave: (newTime) {
          if (_isDuplicate(items, newTime, null)) {
            ToastUtils.showToast(context, 'reminder_time_duplicate'.tr);
            return;
          }
          ctrl.addSchedule(
            ReminderSchedule(mode: 'custom', time: newTime, label: ''),
          );
        },
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(
          color: ob.textActiveBottomNavBar.withValues(alpha: 0.4),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: addTime,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          splashColor: _splash,
          highlightColor: _highlight,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_rounded,
                  size: 18,
                  color: ob.textActiveBottomNavBar,
                ),
                const SizedBox(width: 6),
                Text(
                  'add'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ob.textActiveBottomNavBar,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _slotIcon(int hour) {
    if (hour < 10) return Icons.wb_sunny_outlined;
    if (hour < 13) return Icons.wb_sunny_rounded;
    if (hour < 17) return Icons.cloud_outlined;
    if (hour < 20) return Icons.nights_stay_outlined;
    return Icons.bedtime_outlined;
  }

  // ── Shared pieces ─────────────────────────────────────────────────────────────

  Widget _card({
    required Widget child,
    EdgeInsets? padding,
    VoidCallback? onTap,
  }) {
    const radius = BorderRadius.all(Radius.circular(16));
    final decoration = BoxDecoration(
      color: Colors.white.withValues(alpha: 0.05),
      borderRadius: radius,
      border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
    );
    final contentPadding = padding ?? const EdgeInsets.all(14);

    if (onTap == null) {
      return Container(
        padding: contentPadding,
        decoration: decoration,
        child: child,
      );
    }
    return DecoratedBox(
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: _splash,
          highlightColor: _highlight,
          child: Padding(padding: contentPadding, child: child),
        ),
      ),
    );
  }

  // Shared ink colours: a soft white wash that reads on both the translucent
  // cards and the blue gradient of a selected chip.
  static final Color _splash = Colors.white.withValues(alpha: 0.16);
  static final Color _highlight = Colors.white.withValues(alpha: 0.07);

  static const Color _iconTint = Color(0xFF96D2A8);

  // Unified icon box — matches the Settings screen (42×42 rounded square,
  // mint icon, subtle white border).
  Widget _iconCircle(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(child: Icon(icon, size: 24, color: _iconTint)),
    );
  }
}

/// Greys out + blocks interaction with [child] when [disabled] is true.
/// Shared by the standard and interval reminder tabs so both switch off
/// together with the master reminder toggle.
class DisabledOverlay extends StatelessWidget {
  final bool disabled;
  final Widget child;

  const DisabledOverlay({
    super.key,
    required this.disabled,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: disabled,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: disabled ? 0.4 : 1.0,
        child: child,
      ),
    );
  }
}

void showWheelTimePicker(
  BuildContext context, {
  required String title,
  required String initialTime,
  required ValueChanged<String> onSave,
  // Default to the unified enhanced layout (headers, glow slots, big preview);
  // callers only pass infoText when a context-specific note applies.
  bool enhanced = true,
  String? subtitle = 'picker_device_format_hint',
  String? infoText,
}) {
  String selectedTime = initialTime;
  PrimaryBottomSheet.show(
    context: context,
    title: title,
    buttonText: 'save',
    onButtonPressed: () {
      Navigator.pop(context);
      onSave(selectedTime);
    },
    content: WheelTimePicker(
      initialTime: initialTime,
      onChanged: (t) => selectedTime = t,
      enhanced: enhanced,
      subtitle: subtitle,
      infoText: infoText,
    ),
  );
}
