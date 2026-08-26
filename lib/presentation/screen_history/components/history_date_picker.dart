import 'package:dsp_base/app_material.dart';
import 'package:waternudge/controller/history_controller.dart';
import 'package:waternudge/presentation/common_components/primary_button.dart';
import 'package:waternudge/presentation/common_components/primary_dialog.dart';
import 'package:waternudge/values/onboarding_theme.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HistoryDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime lastDate;

  /// Which granularity to pick — mirrors the active history tab.
  final HistoryViewMode mode;

  const HistoryDatePicker({
    super.key,
    required this.initialDate,
    required this.lastDate,
    this.mode = HistoryViewMode.day,
  });

  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime lastDate,
    HistoryViewMode mode = HistoryViewMode.day,
  }) {
    return showDialog<DateTime>(
      context: context,
      builder: (context) => HistoryDatePicker(
        initialDate: initialDate,
        lastDate: lastDate,
        mode: mode,
      ),
    );
  }

  @override
  State<HistoryDatePicker> createState() => _HistoryDatePickerState();
}

class _HistoryDatePickerState extends State<HistoryDatePicker> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  /// Year window origin for the year grid (shows _yearBase-11 .. _yearBase).
  late int _yearBase;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _yearBase = widget.lastDate.year;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isAfterDay(DateTime a, DateTime b) {
    final aBase = DateTime(a.year, a.month, a.day);
    final bBase = DateTime(b.year, b.month, b.day);
    return aBase.isAfter(bBase);
  }

  // ── Week helpers ─────────────────────────────────────────────────────────
  DateTime _weekStart(DateTime d) =>
      DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));

  bool _inSelectedWeek(DateTime date) {
    final ws = _weekStart(_selectedDate);
    final we = ws.add(const Duration(days: 6));
    final b = DateTime(date.year, date.month, date.day);
    return !b.isBefore(ws) && !b.isAfter(we);
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.mode) {
      case HistoryViewMode.year:
        return _buildYearPicker(context);
      case HistoryViewMode.month:
        return _buildMonthPicker(context);
      case HistoryViewMode.day:
      case HistoryViewMode.week:
        return _buildDayPicker(context);
    }
  }

  // ── Shared header ─────────────────────────────────────────────────────────
  Widget _header(
    OnboardingTheme ob,
    String title, {
    required VoidCallback onPrev,
    VoidCallback? onNext,
    bool canGoNext = true,
  }) {
    return AppRow(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppIcon(
          'assets/images/svg/ic_back_left.svg',
          size: 24,
          onClick: onPrev,
          tint: ob.textPrimary,
          autoMirror: true,
        ),
        AppText(
          title,
          style: TextStyle(
            color: ob.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Opacity(
          opacity: canGoNext ? 1.0 : 0.3,
          child: IgnorePointer(
            ignoring: !canGoNext,
            child: AppIcon(
              'assets/images/svg/ic_back_right.svg',
              size: 24,
              onClick: onNext ?? () {},
              tint: ob.textPrimary,
              autoMirror: true,
            ),
          ),
        ),
      ],
    );
  }

  /// One tappable cell used by the month/year grids.
  Widget _gridCell(
    OnboardingTheme ob, {
    required String label,
    required bool selected,
    required bool disabled,
    required VoidCallback onTap,
    // [plain] mode: no filled background — clean like the streak calendar,
    // only the active day gets a rounded (8px) cyan border.
    bool plain = false,
    // [muted] mode: adjacent-month filler days shown faded.
    bool muted = false,
  }) {
    final Color textColor;
    if (selected) {
      textColor = ob.switchActive;
    } else if (muted) {
      textColor = ob.textPrimary.withValues(alpha: 0.25);
    } else if (disabled) {
      textColor = ob.textSecondary;
    } else {
      textColor = ob.textPrimary;
    }
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected
              ? (plain ? ob.switchActive.withValues(alpha: 0.12) : ob.borderOption)
              : (plain ? Colors.transparent : ob.bgOption),
          borderRadius: BorderRadius.circular(8),
          border: selected
              ? Border.all(color: ob.switchActive, width: 1.5)
              : null,
        ),
        alignment: Alignment.center,
        child: AppText(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Bottom Apply button — commits the current selection and closes.
  Widget _applyFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: PrimaryButton(
        text: 'Áp dụng',
        useGradient: true,
        width: double.infinity,
        height: 46,
        onPressed: () => Navigator.pop(context, _selectedDate),
      ),
    );
  }

  // ── Day / Week picker ─────────────────────────────────────────────────────
  Widget _buildDayPicker(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final offset = firstDayOfMonth.weekday - 1; // Mon=0 .. Sun=6
    final totalCells = daysInMonth + offset;
    final rowCount = (totalCells / 7).ceil();
    // Monday on/before the 1st — grid start, so adjacent-month days fill the
    // leading/trailing blanks (streak-calendar style).
    final gridStart = firstDayOfMonth.subtract(Duration(days: offset));
    final weekdays = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

    final lastMonth = DateTime(widget.lastDate.year, widget.lastDate.month);
    final canGoNext = _currentMonth.isBefore(lastMonth);
    final isWeek = widget.mode == HistoryViewMode.week;

    return PrimaryDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(
            ob,
            DateFormat('MMMM', Get.locale?.languageCode).format(_currentMonth),
            onPrev: () => setState(
              () => _currentMonth = DateTime(
                _currentMonth.year,
                _currentMonth.month - 1,
              ),
            ),
            onNext: () => setState(
              () => _currentMonth = DateTime(
                _currentMonth.year,
                _currentMonth.month + 1,
              ),
            ),
            canGoNext: canGoNext,
          ),
          AppRow(
            modifier: Modifier.padding(horizontal: 16),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekdays
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: AppText(
                        d.tr,
                        style: TextStyle(
                          color: ob.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const AppSpacerH(12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: rowCount * 7,
              itemBuilder: (context, index) {
                final date = gridStart.add(Duration(days: index));
                final inMonth = date.month == _currentMonth.month;
                final selected =
                    inMonth &&
                    (isWeek
                        ? _inSelectedWeek(date)
                        : _isSameDay(date, _selectedDate));
                final disabled = _isAfterDay(date, widget.lastDate);

                return _gridCell(
                  ob,
                  label: '${date.day}',
                  selected: selected,
                  disabled: disabled,
                  plain: true,
                  muted: !inMonth,
                  onTap: () {
                    if (inMonth) setState(() => _selectedDate = date);
                  },
                );
              },
            ),
          ),
          _applyFooter(context),
        ],
      ),
    );
  }

  // ── Month picker (months of a year) ───────────────────────────────────────
  Widget _buildMonthPicker(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final year = _currentMonth.year;
    final canGoNext = year < widget.lastDate.year;

    return PrimaryDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(
            ob,
            '$year',
            onPrev: () => setState(
              () => _currentMonth = DateTime(year - 1, _currentMonth.month),
            ),
            onNext: () => setState(
              () => _currentMonth = DateTime(year + 1, _currentMonth.month),
            ),
            canGoNext: canGoNext,
          ),
          const AppSpacerH(12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.8,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final date = DateTime(year, month, 1);
                final selected =
                    _selectedDate.year == year && _selectedDate.month == month;
                final disabled =
                    year > widget.lastDate.year ||
                    (year == widget.lastDate.year &&
                        month > widget.lastDate.month);
                final label = DateFormat(
                  'MMM',
                  Get.locale?.languageCode,
                ).format(date);

                return _gridCell(
                  ob,
                  label: label,
                  selected: selected,
                  disabled: disabled,
                  onTap: () => setState(() => _selectedDate = date),
                );
              },
            ),
          ),
          _applyFooter(context),
        ],
      ),
    );
  }

  // ── Year picker (12-year window) ──────────────────────────────────────────
  Widget _buildYearPicker(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final startYear = _yearBase - 11;
    // Previous block always allowed; next block only up to lastDate.year.
    final canGoNext = _yearBase < widget.lastDate.year;

    return PrimaryDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(
            ob,
            '$startYear - $_yearBase',
            onPrev: () => setState(() => _yearBase -= 12),
            onNext: () => setState(
              () => _yearBase = (_yearBase + 12).clamp(
                widget.lastDate.year - 11,
                widget.lastDate.year,
              ),
            ),
            canGoNext: canGoNext,
          ),
          const AppSpacerH(12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.8,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final year = startYear + index;
                final date = DateTime(year, 1, 1);
                final selected = _selectedDate.year == year;
                final disabled = year > widget.lastDate.year;

                return _gridCell(
                  ob,
                  label: '$year',
                  selected: selected,
                  disabled: disabled,
                  onTap: () => setState(() => _selectedDate = date),
                );
              },
            ),
          ),
          _applyFooter(context),
        ],
      ),
    );
  }
}
