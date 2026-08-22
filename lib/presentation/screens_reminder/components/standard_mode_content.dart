import 'package:dsp_base/app_material.dart';
import 'package:get/get.dart';
import 'package:smartdrinkai/controller/reminder_controller.dart';
import 'package:smartdrinkai/models/data_models/reminder_schedule.dart';
import 'package:smartdrinkai/presentation/common_components/custom_switch.dart';
import 'package:smartdrinkai/presentation/common_components/primary_bottom_sheet.dart';
import 'package:smartdrinkai/presentation/common_components/wheel_time_picker.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';

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
        _buildEnableCard(),
        const SizedBox(height: 12),
        _buildWindowRow(),
        const SizedBox(height: 18),
        _buildScheduleApply(),
        const SizedBox(height: 18),
        _buildWeekendCard(),
        const SizedBox(height: 18),
        _buildSlots(),
        const SizedBox(height: 18),
        _buildSoundRow(),
        const SizedBox(height: 10),
        _buildPriorityRow(),
      ],
    );
  }

  // ── Enable card ─────────────────────────────────────────────────────────────

  Widget _buildEnableCard() {
    final ob = OnboardingTheme.of(context);
    return _card(
      child: Row(
        children: [
          _iconCircle(Icons.notifications_outlined, const Color(0xFF4FC3F7)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bật nhắc nhở uống nước',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ob.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Nhận thông báo nhắc uống nước\nđể duy trì thói quen lành mạnh.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    color: ob.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Obx(
            () => CustomSwitch(
              value: ctrl.enabled.value,
              onChanged: (v) {
                ctrl.enabled.value = v;
                ctrl.saveSettings();
              },
              activeColor: ob.switchActive,
              trackColor: ob.switchTrack,
            ),
          ),
        ],
      ),
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
          _iconCircle(Icons.schedule_rounded, const Color(0xFF4FC3F7),
              size: 36),
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
          Icon(Icons.chevron_right_rounded,
              size: 20, color: ob.textSecondary),
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
          return Row(
            children: [
              _presetChip(Icons.calendar_month_rounded, 'Every day', null,
                  preset == 'everyday', () => _setPreset([1, 2, 3, 4, 5, 6, 7])),
              const SizedBox(width: 8),
              _presetChip(Icons.calendar_view_week_rounded, 'Weekdays',
                  'T2 - T6', preset == 'weekdays', () => _setPreset([1, 2, 3, 4, 5])),
              const SizedBox(width: 8),
              _presetChip(Icons.weekend_outlined, 'Weekends', 'T7 - CN',
                  preset == 'weekends', () => _setPreset([6, 7])),
              const SizedBox(width: 8),
              _presetChip(Icons.edit_calendar_outlined, 'Custom', 'Chọn ngày',
                  preset == 'custom', null),
            ],
          );
        }),
        const SizedBox(height: 12),
        Obx(() {
          final days = ctrl.repeatDays;
          return Row(
            children: [
              for (var d = 1; d <= 7; d++) ...[
                _dayChip(_dayLabels[d - 1], days.contains(d),
                    () => ctrl.toggleDay(d)),
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
              _iconCircle(Icons.timer_outlined, const Color(0xFF4FC3F7),
                  size: 36),
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
            Icon(Icons.chevron_right_rounded,
                size: 20, color: ob.textSecondary),
          ],
        ),
      ),
    );
  }

  // ── Reminder slots ────────────────────────────────────────────────────────────

  Widget _buildSlots() {
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

  Widget _slotRow(String label, ReminderSchedule? schedule, String fallback) {
    final ob = OnboardingTheme.of(context);
    final time = schedule?.time ?? fallback;
    final enabled = schedule?.enabled ?? true;
    final hour = int.tryParse(time.split(':').first) ?? 8;

    return _card(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _iconCircle(_slotIcon(hour), _slotColor(hour), size: 34, iconSize: 17),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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

  // ── Sound / priority rows ─────────────────────────────────────────────────────

  Widget _buildSoundRow() {
    final ob = OnboardingTheme.of(context);
    return _card(
      child: Row(
        children: [
          _iconCircle(Icons.volume_up_rounded, const Color(0xFF4FC3F7),
              size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Âm thanh nhắc',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ob.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Chọn âm thanh cho thông báo nhắc uống nước.',
                  style: TextStyle(fontSize: 11, color: ob.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            'Giọt nước',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ob.textActiveBottomNavBar,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 20, color: ob.textSecondary),
        ],
      ),
    );
  }

  Widget _buildPriorityRow() {
    final ob = OnboardingTheme.of(context);
    return _card(
      child: Row(
        children: [
          _iconCircle(Icons.notifications_active_outlined,
              const Color(0xFF4FC3F7), size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Độ ưu tiên thông báo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ob.textPrimary,
              ),
            ),
          ),
          Text(
            'Cao',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ob.textActiveBottomNavBar,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 20, color: ob.textSecondary),
        ],
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

  Widget _iconCircle(
    IconData icon,
    Color color, {
    double size = 44,
    double? iconSize,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Icon(icon, size: iconSize ?? size * 0.42, color: color),
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
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? Colors.white
                    : ob.textActiveBottomNavBar,
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
                  color: selected
                      ? Colors.white
                      : ob.textPrimary,
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

  IconData _slotIcon(int hour) {
    if (hour < 10) return Icons.wb_sunny_outlined;
    if (hour < 13) return Icons.wb_sunny_rounded;
    if (hour < 17) return Icons.cloud_outlined;
    if (hour < 20) return Icons.nights_stay_outlined;
    return Icons.bedtime_outlined;
  }

  Color _slotColor(int hour) {
    if (hour < 10) return const Color(0xFFFFB300);
    if (hour < 13) return const Color(0xFFFFC107);
    if (hour < 17) return const Color(0xFF42A5F5);
    if (hour < 20) return const Color(0xFF5C6BC0);
    return const Color(0xFF7E57C2);
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
