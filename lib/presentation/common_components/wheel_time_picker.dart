import 'package:flutter/material.dart';
import 'package:waternudge/presentation/common_components/wheel_picker_chrome.dart';
import 'package:waternudge/utils/unit_converter.dart';
import 'package:waternudge/values/onboarding_theme.dart';
import 'package:get/get.dart';

class WheelTimePicker extends StatefulWidget {
  final String initialTime; // "HH:mm" format (24h)
  final ValueChanged<String> onChanged;
  final Color? colorBorder;

  /// Enhanced layout: column headers (Giờ/Phút), glowing selection boxes,
  /// big time preview and an optional info pill. Used by the "nap range" and
  /// "reminder window" bottom sheets. Other call sites keep the compact look.
  final bool enhanced;

  /// Localization key shown as a hint under the sheet title (enhanced only).
  final String? subtitle;

  /// Localization key shown in the moon info pill (enhanced only).
  final String? infoText;

  const WheelTimePicker({
    super.key,
    required this.initialTime,
    required this.onChanged,
    this.colorBorder,
    this.enhanced = false,
    this.subtitle,
    this.infoText,
  });

  @override
  State<WheelTimePicker> createState() => _WheelTimePickerState();
}

class _WheelTimePickerState extends State<WheelTimePicker> {
  // Follows the device's 24h/12h setting: the 24h device gets a 0-23 hour
  // wheel (unchanged); the 12h device gets a 1-12 wheel plus an AM/PM wheel,
  // matching how the saved time is later displayed everywhere else
  // (`UnitConverter.formatTime` / `ReminderController.formatDisplayTime`).
  late final bool _use24h;

  /// Source of truth, always 0-23 — what `widget.onChanged` receives.
  late int _hour;
  late int _minute;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  /// Wheel index: 0-23 when `_use24h`, otherwise 0-11 (hour-of-12 minus 1).
  late int _selectedHourIndex;
  late int _selectedMinuteIndex;

  /// 12h-only AM/PM wheel: 0 = AM, 1 = PM.
  late int _periodIndex;
  FixedExtentScrollController? _periodController;

  @override
  void initState() {
    super.initState();
    _use24h = UnitConverter.deviceUses24h();
    final parts = widget.initialTime.split(':');
    _hour = int.tryParse(parts[0]) ?? 7;
    _minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    if (_use24h) {
      _selectedHourIndex = _hour;
      _periodIndex = 0;
    } else {
      final hour12 = _hour % 12 == 0 ? 12 : _hour % 12;
      _selectedHourIndex = hour12 - 1;
      _periodIndex = _hour >= 12 ? 1 : 0;
      _periodController = FixedExtentScrollController(
        initialItem: _periodIndex,
      );
    }
    _selectedMinuteIndex = _minute;

    _hourController = FixedExtentScrollController(
      initialItem: _selectedHourIndex,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinuteIndex,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController?.dispose();
    super.dispose();
  }

  /// Recomputes the true 24h `_hour` from the 12h wheel + AM/PM wheel.
  void _applyHour12() {
    final hour12 = _selectedHourIndex + 1; // 1..12
    final isPm = _periodIndex == 1;
    if (hour12 == 12) {
      _hour = isPm ? 12 : 0;
    } else {
      _hour = isPm ? hour12 + 12 : hour12;
    }
  }

  void _notifyChange() {
    final result =
        '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';
    widget.onChanged(result);
  }

  String _two(int i) => i.toString().padLeft(2, '0');

  /// Preview text in the device's format, e.g. "21:00" or "09:00 PM".
  String get _previewText {
    if (_use24h) return '${_two(_hour)}:${_two(_minute)}';
    final hour12 = _selectedHourIndex + 1;
    final period = _periodIndex == 1 ? 'pm'.tr : 'am'.tr;
    return '${_two(hour12)}:${_two(_minute)} $period';
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int) labelBuilder,
    required ValueChanged<int> onChanged,
    required int selectedIndex,
    double width = 60,
  }) {
    final bool isLooping = itemCount > 2;
    final double selectedSize = widget.enhanced
        ? WheelPickerChrome.selectedFontSize
        : 32;
    final double unselectedSize = widget.enhanced
        ? WheelPickerChrome.unselectedFontSize
        : 16;

    Widget itemFor(int index, int selected) {
      int distance = (index - selected).abs();
      if (isLooping) {
        final half = itemCount ~/ 2;
        if (distance > half) distance = itemCount - distance;
      }
      return WheelPickerChrome.wheelItem(
        context,
        labelBuilder(index),
        distance,
        selectedSize: selectedSize,
        unselectedSize: unselectedSize,
      );
    }

    return SizedBox(
      width: width,
      height: WheelPickerChrome.wheelHeight,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: WheelPickerChrome.slotHeight,
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
                children: List.generate(
                  itemCount,
                  (index) => itemFor(index, selectedIndex),
                ),
              )
            : ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  if (index >= itemCount || index < 0) return null;
                  return itemFor(index, selectedIndex);
                },
                childCount: itemCount,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final double hourW = widget.enhanced ? 96 : 60;
    final double minW = widget.enhanced ? 96 : 60;
    final double periodW = widget.enhanced ? 72 : 46;

    Widget hourWheel = _buildWheel(
      controller: _hourController,
      itemCount: _use24h ? 24 : 12,
      labelBuilder: (i) => _use24h ? _two(i) : _two(i + 1),
      selectedIndex: _selectedHourIndex,
      width: hourW,
      onChanged: (i) {
        setState(() {
          _selectedHourIndex = i;
          if (_use24h) {
            _hour = i;
          } else {
            _applyHour12();
          }
        });
        _notifyChange();
      },
    );

    Widget minuteWheel = _buildWheel(
      controller: _minuteController,
      itemCount: 60,
      labelBuilder: _two,
      selectedIndex: _selectedMinuteIndex,
      width: minW,
      onChanged: (i) {
        setState(() {
          _selectedMinuteIndex = i;
          _minute = i;
        });
        _notifyChange();
      },
    );

    Widget? periodWheel = _use24h
        ? null
        : _buildWheel(
            controller: _periodController!,
            itemCount: 2,
            labelBuilder: (i) => (i == 0 ? 'am'.tr : 'pm'.tr).toUpperCase(),
            selectedIndex: _periodIndex,
            width: periodW,
            onChanged: (i) {
              setState(() {
                _periodIndex = i;
                _applyHour12();
              });
              _notifyChange();
            },
          );

    // Compact layout (default): original full-width band highlight.
    if (!widget.enhanced) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
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
              hourWheel,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: ob.textPrimary,
                  ),
                ),
              ),
              minuteWheel,
              if (periodWheel != null) ...[
                const SizedBox(width: 8),
                periodWheel,
              ],
            ],
          ),
        ],
      );
    }

    // Enhanced layout: each column stacks its header over its wheel so labels
    // stay aligned; the ":" is nudged down to the wheel's centre band.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.subtitle != null) ...[
          WheelPickerChrome.subtitle(context, widget.subtitle!),
          const SizedBox(height: 20),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WheelPickerChrome.labeledColumn(
              context,
              hourW,
              'picker_hour',
              hourWheel,
            ),
            WheelPickerChrome.separator(context),
            WheelPickerChrome.labeledColumn(
              context,
              minW,
              'picker_minute',
              minuteWheel,
            ),
            if (periodWheel != null) ...[
              const SizedBox(width: 12),
              WheelPickerChrome.labeledColumn(
                context,
                periodW,
                'picker_period',
                periodWheel,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        WheelPickerChrome.gradientPreview(context, _previewText),
        if (widget.infoText != null) ...[
          const SizedBox(height: 20),
          WheelPickerChrome.infoPill(
            context,
            icon: Icons.bedtime_rounded,
            text: widget.infoText!.tr,
          ),
        ],
      ],
    );
  }
}
