import 'package:dsp_base/app_material.dart';
import 'package:get/get.dart';
import 'package:waternudge/controller/reminder_controller.dart';
import 'package:waternudge/presentation/common_components/custom_switch.dart';
import 'package:waternudge/presentation/common_components/primary_bottom_sheet.dart';
import 'package:waternudge/presentation/common_components/wheel_time_picker.dart';
import 'package:waternudge/values/onboarding_theme.dart';

/// The "Standard mode" form of the reminder screen: master switch, active
/// window, weekly schedule presets, an optional separate weekend window, the
/// per-slot reminder list, and sound / priority rows.
class StandardModeContent extends StatefulWidget {
  final ReminderController controller;
  const StandardModeContent({super.key, required this.controller});

  @override
  State<StandardModeContent> createState() => _StandardModeContentState();
}

class _StandardModeContentState extends State<StandardModeContent> {
  ReminderController get ctrl => widget.controller;

  // Local UI state — not yet persisted (TODO: wire to prefs / controller).
  String _activeStart = '08:00';
  String _activeEnd = '22:00';
  bool _weekendSeparate = false;
  String _weekdayStart = '08:00';
  String _weekdayEnd = '22:00';
  String _weekendStart = '09:00';
  String _weekendEnd = '23:00';

  static const _dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
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
                _buildWindowRow(),
                const SizedBox(height: 18),
                _buildScheduleApply(),
                const SizedBox(height: 18),
                _buildWeekendCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Active time window ────────────────────────────────────────────────────────

  Widget _buildWindowRow() {
    final ob = OnboardingTheme.of(context);
    return _card(
      onTap: () => _pickRange(
        start: _activeStart,
        end: _activeEnd,
        onSaved: (s, e) => setState(() {
          _activeStart = s;
          _activeEnd = e;
        }),
      ),
      child: Row(
        children: [
          _iconCircle(
            Icons.schedule_rounded,
            const Color(0xFF4FC3F7),
            size: 36,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Khung giờ nhắc',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ob.textPrimary,
              ),
            ),
          ),
          _rangePill(_activeStart, _activeEnd),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 20, color: ob.textSecondary),
        ],
      ),
    );
  }

  // ── Apply schedule: presets + day chips ─────────────────────────────────────

  Widget _buildScheduleApply() {
    final ob = OnboardingTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Áp dụng lịch nhắc',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: ob.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Chọn những ngày bạn muốn áp dụng lịch nhắc này.',
          style: TextStyle(fontSize: 11, color: ob.textSecondary),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final preset = _preset;
          // IntrinsicHeight + stretch → all four cards share the tallest height
          // even though 'Every day' has no subtitle line.
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _presetChip(
                  Icons.calendar_month_rounded,
                  'Every day',
                  null,
                  preset == 'everyday',
                  () => _setPreset([1, 2, 3, 4, 5, 6, 7]),
                ),
                const SizedBox(width: 8),
                _presetChip(
                  Icons.calendar_view_week_rounded,
                  'Weekdays',
                  'T2 - T6',
                  preset == 'weekdays',
                  () => _setPreset([1, 2, 3, 4, 5]),
                ),
                const SizedBox(width: 8),
                _presetChip(
                  Icons.weekend_outlined,
                  'Weekends',
                  'T7 - CN',
                  preset == 'weekends',
                  () => _setPreset([6, 7]),
                ),
                const SizedBox(width: 8),
                _presetChip(
                  Icons.edit_calendar_outlined,
                  'Custom',
                  'Chọn ngày',
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
                  _dayLabels[d - 1],
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

  // ── Separate weekend window ─────────────────────────────────────────────────

  Widget _buildWeekendCard() {
    final ob = OnboardingTheme.of(context);
    final subColor = _weekendSeparate
        ? ob.textPrimary
        : ob.textSecondary.withValues(alpha: 0.5);
    return _card(
      child: Column(
        children: [
          Row(
            children: [
              _iconCircle(
                Icons.timer_outlined,
                const Color(0xFF4FC3F7),
                size: 36,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lịch cuối tuần riêng',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ob.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Thiết lập khung giờ khác cho cuối tuần.',
                      style: TextStyle(fontSize: 11, color: ob.textSecondary),
                    ),
                  ],
                ),
              ),
              CustomSwitch(
                value: _weekendSeparate,
                onChanged: (v) => setState(() => _weekendSeparate = v),
                activeColor: ob.switchActive,
                trackColor: ob.switchTrack,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _weekendSubRow(
            'Ngày thường',
            _weekdayStart,
            _weekdayEnd,
            subColor,
            enabled: _weekendSeparate,
            onTap: () => _pickRange(
              start: _weekdayStart,
              end: _weekdayEnd,
              onSaved: (s, e) => setState(() {
                _weekdayStart = s;
                _weekdayEnd = e;
              }),
            ),
          ),
          const SizedBox(height: 10),
          _weekendSubRow(
            'Cuối tuần',
            _weekendStart,
            _weekendEnd,
            subColor,
            enabled: _weekendSeparate,
            onTap: () => _pickRange(
              start: _weekendStart,
              end: _weekendEnd,
              onSaved: (s, e) => setState(() {
                _weekendStart = s;
                _weekendEnd = e;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weekendSubRow(
    String label,
    String start,
    String end,
    Color labelColor, {
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final ob = OnboardingTheme.of(context);
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 13, color: labelColor),
              ),
            ),
            _rangePill(start, end),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: ob.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared pieces ─────────────────────────────────────────────────────────────

  Widget _card({
    required Widget child,
    EdgeInsets? padding,
    VoidCallback? onTap,
  }) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }

  // Unified icon box — matches the Settings screen (42×42 rounded square,
  // mint icon, subtle white border). [color]/[size] are ignored so every
  // reminder icon is identical.
  Widget _iconCircle(IconData icon, Color color, {double size = 44}) {
    return _settingsIconBox(icon);
  }

  static const Color _iconTint = Color(0xFF96D2A8);

  Widget _settingsIconBox(IconData icon) {
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

  Widget _rangePill(String start, String end) {
    final ob = OnboardingTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(
          color: ob.textActiveBottomNavBar.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        '$start  —  $end',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: ob.textActiveBottomNavBar,
        ),
      ),
    );
  }

  Widget _presetChip(
    IconData icon,
    String title,
    String? sub,
    bool selected,
    VoidCallback? onTap,
  ) {
    final ob = OnboardingTheme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF1575CE), Color(0xFF0B58D6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
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
    );
  }

  Widget _dayChip(String label, bool selected, VoidCallback onTap) {
    final ob = OnboardingTheme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF1575CE)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
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
    );
  }

  // ── Logic helpers ─────────────────────────────────────────────────────────────

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

  /// Pick a start then end time, updating via [onSaved].
  Future<void> _pickRange({
    required String start,
    required String end,
    required void Function(String start, String end) onSaved,
  }) async {
    String newStart = start;
    String newEnd = end;
    showWheelTimePicker(
      context,
      title: 'Từ',
      initialTime: start,
      onSave: (s) {
        newStart = s;
        showWheelTimePicker(
          context,
          title: 'Đến',
          initialTime: end,
          onSave: (e) {
            newEnd = e;
            onSaved(newStart, newEnd);
          },
        );
      },
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
