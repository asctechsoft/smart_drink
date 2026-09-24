import 'package:dsp_base/app_material.dart';
import 'package:get/get.dart';
import 'package:waternudge/controller/reminder_controller.dart';
import 'package:waternudge/values/onboarding_theme.dart';

/// "Apply schedule": weekday presets + the day-of-week chip row. Shown once
/// above the Standard / Interval / Custom mode tabs since which days a
/// reminder repeats on is shared across every mode, not just Standard's.
class ScheduleApplySection extends StatelessWidget {
  final ReminderController ctrl;
  const ScheduleApplySection({super.key, required this.ctrl});

  static const _dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  static final Color _splash = Colors.white.withValues(alpha: 0.16);
  static final Color _highlight = Colors.white.withValues(alpha: 0.07);

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final preset = _preset;
          // IntrinsicHeight + stretch → all four cards share the tallest height
          // even though 'Every day' has no subtitle line.
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _presetChip(
                  context,
                  Icons.calendar_month_rounded,
                  'preset_everyday'.tr,
                  null,
                  preset == 'everyday',
                  () => _setPreset([1, 2, 3, 4, 5, 6, 7]),
                ),
                const SizedBox(width: 8),
                _presetChip(
                  context,
                  Icons.calendar_view_week_rounded,
                  'preset_weekdays'.tr,
                  'preset_weekdays_range'.tr,
                  preset == 'weekdays',
                  () => _setPreset([1, 2, 3, 4, 5]),
                ),
                const SizedBox(width: 8),
                _presetChip(
                  context,
                  Icons.weekend_outlined,
                  'preset_weekends'.tr,
                  'preset_weekends_range'.tr,
                  preset == 'weekends',
                  () => _setPreset([6, 7]),
                ),
                const SizedBox(width: 8),
                _presetChip(
                  context,
                  Icons.edit_calendar_outlined,
                  'preset_custom'.tr,
                  'preset_custom_sub'.tr,
                  preset == 'custom',
                  null,
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        Obx(() {
          final days = ctrl.repeatDays;
          return Row(
            children: [
              for (var d = 1; d <= 7; d++) ...[
                _dayChip(
                  context,
                  _dayLabels[d - 1].tr,
                  days.contains(d),
                  () => ctrl.toggleDay(d),
                ),
                if (d < 7) const SizedBox(width: 6),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _presetChip(
    BuildContext context,
    IconData icon,
    String title,
    String? sub,
    bool selected,
    VoidCallback? onTap,
  ) {
    final ob = OnboardingTheme.of(context);
    const radius = BorderRadius.all(Radius.circular(12));
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFF1575CE), Color(0xFF0B58D6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.05),
          borderRadius: radius,
          border: Border.all(
            color: selected
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          // The "custom" preset passes a null onTap — it is a state readout,
          // not a button — so InkWell leaves it inert and rippleless.
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            splashColor: _splash,
            highlightColor: _highlight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: selected ? Colors.white : ob.textActiveBottomNavBar,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : ob.textPrimary,
                    ),
                  ),
                  if (sub != null)
                    Text(
                      sub,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: selected
                            ? Colors.white.withValues(alpha: 0.85)
                            : ob.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dayChip(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    final ob = OnboardingTheme.of(context);
    const radius = BorderRadius.all(Radius.circular(100));
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1575CE)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: radius,
          border: Border.all(
            color: selected
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            splashColor: _splash,
            highlightColor: _highlight,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : ob.textPrimary.withValues(alpha: 0.85),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _preset {
    final d = ctrl.repeatDays;
    if (d.length == 7) return 'everyday';
    if (_sameSet(d, const [1, 2, 3, 4, 5])) return 'weekdays';
    if (_sameSet(d, const [6, 7])) return 'weekends';
    return 'custom';
  }

  bool _sameSet(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    return b.every(a.contains);
  }

  void _setPreset(List<int> days) {
    ctrl.repeatDays.assignAll(days);
    ctrl.saveSettings();
  }
}
