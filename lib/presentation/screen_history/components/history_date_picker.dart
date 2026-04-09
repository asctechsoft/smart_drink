import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/presentation/common_components/primary_dialog.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HistoryDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime lastDate;

  const HistoryDatePicker({
    super.key,
    required this.initialDate,
    required this.lastDate,
  });

  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime lastDate,
  }) {
    return showDialog<DateTime>(
      context: context,
      builder: (context) =>
          HistoryDatePicker(initialDate: initialDate, lastDate: lastDate),
    );
  }

  @override
  State<HistoryDatePicker> createState() => _HistoryDatePickerState();
}

class _HistoryDatePickerState extends State<HistoryDatePicker> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isAfterDay(DateTime a, DateTime b) {
    final aBase = DateTime(a.year, a.month, a.day);
    final bBase = DateTime(b.year, b.month, b.day);
    return aBase.isAfter(bBase);
  }

  bool get _canGoNextMonth {
    final lastMonth = DateTime(widget.lastDate.year, widget.lastDate.month);
    return _currentMonth.isBefore(lastMonth);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final offset = firstDayOfMonth.weekday - 1; // 1=Mon, 7=Sun -> 0=Mon, 6=Sun
    final totalCells = daysInMonth + offset;
    final rowCount = (totalCells / 7).ceil();

    final weekdays = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

    return PrimaryDialog(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          AppRow(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppIcon(
                'assets/images/svg/ic_back_left.svg',
                size: 24,
                onClick: _previousMonth,
                tint: ob.textPrimary,
                autoMirror: true,
              ),
              AppText(
                DateFormat(
                  'MMMM',
                  Get.locale?.languageCode,
                ).format(_currentMonth),
                style: TextStyle(
                  color: ob.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Opacity(
                opacity: _canGoNextMonth ? 1.0 : 0.3,
                child: IgnorePointer(
                  ignoring: !_canGoNextMonth,
                  child: AppIcon(
                    'assets/images/svg/ic_back_right.svg',
                    size: 24,
                    onClick: _nextMonth,
                    tint: ob.textPrimary,
                    autoMirror: true,
                  ),
                ),
              ),
            ],
          ),
          // Weekdays
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
          // Days grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: rowCount * 7,
              itemBuilder: (context, index) {
                if (index < offset || index >= offset + daysInMonth) {
                  return const SizedBox.shrink();
                }
                final day = index - offset + 1;
                final date = DateTime(
                  _currentMonth.year,
                  _currentMonth.month,
                  day,
                );
                final isSelected = _isSameDay(date, _selectedDate);
                final isDisabled = _isAfterDay(date, widget.lastDate);

                return GestureDetector(
                  onTap: () {
                    if (!isDisabled) {
                      setState(() {
                        _selectedDate = date;
                      });
                      Navigator.pop(context, date);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? ob.borderOption : ob.bgOption,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: ob.switchActive, width: 1.5)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: AppText(
                      '$day',
                      style: TextStyle(
                        color: isSelected
                            ? ob.switchActive
                            : (isDisabled ? ob.textSecondary : ob.textPrimary),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

