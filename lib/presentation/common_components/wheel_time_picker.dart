import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';

class WheelTimePicker extends StatefulWidget {
  final String initialTime; // "HH:mm" format (24h)
  final ValueChanged<String> onChanged;
  final Color? colorBorder;

  const WheelTimePicker({
    super.key,
    required this.initialTime,
    required this.onChanged,
    this.colorBorder,
  });

  @override
  State<WheelTimePicker> createState() => _WheelTimePickerState();
}

class _WheelTimePickerState extends State<WheelTimePicker> {
  late int _hour;
  late int _minute;
  late bool _isAm;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _amPmController;
  late int _selectedHourIndex;
  late int _selectedMinuteIndex;
  late int _selectedAmPmIndex;

  bool get is12hMode {
    final settingsCtrl = Get.find<SettingsController>();
    if (settingsCtrl.timeFormat.value == 'system') {
      final ctx = Get.context;
      if (ctx != null) return !MediaQuery.of(ctx).alwaysUse24HourFormat;
      return false;
    }
    return settingsCtrl.timeFormat.value == '12h';
  }

  @override
  void initState() {
    super.initState();
    final is12h = is12hMode;

    final parts = widget.initialTime.split(':');
    final h24 = int.tryParse(parts[0]) ?? 7;
    _minute = int.tryParse(parts[1]) ?? 0;

    if (is12h) {
      _isAm = h24 < 12;
      _hour = h24 % 12; // 0h->0, 12h->0
      _selectedHourIndex = _hour;
      _selectedAmPmIndex = _isAm ? 0 : 1;
    } else {
      _hour = h24;
      _selectedHourIndex = h24;
      _selectedAmPmIndex = 0; // Không dùng nhưng vẫn init
      _isAm = true;
    }

    _selectedMinuteIndex = _minute;

    _hourController = FixedExtentScrollController(
      initialItem: _selectedHourIndex,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinuteIndex,
    );
    _amPmController = FixedExtentScrollController(
      initialItem: _selectedAmPmIndex,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _amPmController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    final is12h = is12hMode;

    int h24;
    if (is12h) {
      h24 = _hour;
      if (!_isAm) h24 += 12;
    } else {
      h24 = _hour;
    }

    final result =
        '${h24.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';
    widget.onChanged(result);
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int) labelBuilder,
    required ValueChanged<int> onChanged,
    required int selectedIndex,
    double width = 60,
  }) {
    final ob = OnboardingTheme.of(context);
    final bool isLooping = itemCount > 2;

    return SizedBox(
      width: width,
      height: 200,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 50,
        physics: const FixedExtentScrollPhysics(),
        overAndUnderCenterOpacity: 1.0,
        onSelectedItemChanged: (i) {
          if (isLooping) {
            int normalized = i % itemCount;
            if (normalized < 0) normalized += itemCount;
            onChanged(normalized);
          } else {
            onChanged(i);
          }
        },
        childDelegate: isLooping
            ? ListWheelChildLoopingListDelegate(
                children: List.generate(itemCount, (index) {
                  int distance = (index - selectedIndex).abs();
                  final half = itemCount ~/ 2;
                  if (distance > half) distance = itemCount - distance;

                  final isSelected = distance == 0;
                  Color itemColor = ob.textPrimary;
                  if (distance == 1) {
                    itemColor = ob.textPrimary.withValues(alpha: 0.5);
                  } else if (distance >= 2) {
                    itemColor = ob.textPrimary.withValues(alpha: 0.1);
                  }

                  return Center(
                    child: AppText(
                      labelBuilder(index).tr,
                      style: TextStyle(
                        fontSize: isSelected ? 32 : 16,
                        fontWeight: FontWeight.w600,
                        color: itemColor,
                      ),
                    ),
                  );
                }),
              )
            : ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  if (index >= itemCount || index < 0) return null;
                  final isSelected = index == selectedIndex;
                  final distance = (index - selectedIndex).abs();
                  Color itemColor = ob.textPrimary;
                  if (distance == 1) {
                    itemColor = ob.textPrimary.withValues(alpha: 0.5);
                  } else if (distance >= 2) {
                    itemColor = ob.textPrimary.withValues(alpha: 0.1);
                  }

                  return Center(
                    child: AppText(
                      labelBuilder(index).tr,
                      style: TextStyle(
                        fontSize: isSelected ? 32 : 16,
                        fontWeight: FontWeight.w600,
                        color: itemColor,
                      ),
                    ),
                  );
                },
                childCount: itemCount,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final is12h = is12hMode;
    final ob = OnboardingTheme.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: widget.colorBorder ?? ob.bgOptionSelected,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildWheel(
              controller: _hourController,
              itemCount: is12h ? 12 : 24,
              labelBuilder: (i) {
                if (is12h && i == 0) return '12';
                return i.toString().padLeft(2, '0');
              },
              selectedIndex: _selectedHourIndex,
              onChanged: (i) {
                setState(() => _selectedHourIndex = i);
                _hour = i;
                _notifyChange();
              },
            ),
            const Text(
              ':',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            _buildWheel(
              controller: _minuteController,
              itemCount: 60,
              labelBuilder: (i) => i.toString().padLeft(2, '0'),
              selectedIndex: _selectedMinuteIndex,
              onChanged: (i) {
                setState(() => _selectedMinuteIndex = i);
                _minute = i;
                _notifyChange();
              },
            ),
            if (is12h) ...[
              const SizedBox(width: 8),
              _buildWheel(
                controller: _amPmController,
                itemCount: 2,
                labelBuilder: (i) => i == 0 ? 'am' : 'pm',
                selectedIndex: _selectedAmPmIndex,
                onChanged: (i) {
                  setState(() => _selectedAmPmIndex = i);
                  _isAm = i == 0;
                  _notifyChange();
                },
                width: 50,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

