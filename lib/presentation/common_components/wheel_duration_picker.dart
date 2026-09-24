import 'package:flutter/material.dart';
import 'package:waternudge/presentation/common_components/primary_bottom_sheet.dart';
import 'package:waternudge/presentation/common_components/wheel_picker_chrome.dart';
import 'package:waternudge/utils/toast_utils.dart';
import 'package:get/get.dart';

/// Hours + minutes duration wheel, styled exactly like the enhanced
/// [WheelTimePicker] used by the sleep / reminder-window sheets: column
/// headers, glowing selection slots, a gradient read-out and an info pill.
class WheelDurationPicker extends StatefulWidget {
  final int initialMinutes;
  final ValueChanged<int> onChanged;

  /// Localization key shown as a hint under the sheet title.
  final String? subtitle;

  /// Localization key for the info pill; receives the formatted duration as
  /// `args1`. Pass null to hide the pill.
  final String? infoText;

  const WheelDurationPicker({
    super.key,
    required this.initialMinutes,
    required this.onChanged,
    this.subtitle = 'interval_picker_hint',
    this.infoText = 'interval_pill_info',
  });

  /// "1 hour 30 min" — matches `ReminderController.intervalDisplay`.
  static String format(int totalMinutes) {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    final hourLabel = '$h ${h <= 1 ? 'hour'.tr : 'hours'.tr}';
    if (h > 0 && m > 0) return '$hourLabel $m ${'min'.tr}';
    if (h > 0) return hourLabel;
    return '$m ${'min'.tr}';
  }

  @override
  State<WheelDurationPicker> createState() => _WheelDurationPickerState();
}

class _WheelDurationPickerState extends State<WheelDurationPicker> {
  static const int _maxHours = 12;
  static const double _colWidth = 96;

  late int _hours;
  late int _minutes;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _hours = (widget.initialMinutes ~/ 60).clamp(0, _maxHours);
    _minutes = widget.initialMinutes % 60;
    _hourController = FixedExtentScrollController(initialItem: _hours);
    _minuteController = FixedExtentScrollController(initialItem: _minutes);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _notifyChange() => widget.onChanged(_hours * 60 + _minutes);

  Widget _hourWheel() {
    return SizedBox(
      width: _colWidth,
      height: WheelPickerChrome.wheelHeight,
      child: ListWheelScrollView.useDelegate(
        controller: _hourController,
        itemExtent: WheelPickerChrome.slotHeight,
        physics: const FixedExtentScrollPhysics(),
        overAndUnderCenterOpacity: 1.0,
        onSelectedItemChanged: (i) {
          setState(() => _hours = i);
          _notifyChange();
        },
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            if (index < 0 || index > _maxHours) return null;
            return WheelPickerChrome.wheelItem(
              context,
              '$index',
              (index - _hours).abs(),
            );
          },
          childCount: _maxHours + 1,
        ),
      ),
    );
  }

  Widget _minuteWheel() {
    return SizedBox(
      width: _colWidth,
      height: WheelPickerChrome.wheelHeight,
      child: ListWheelScrollView.useDelegate(
        controller: _minuteController,
        itemExtent: WheelPickerChrome.slotHeight,
        physics: const FixedExtentScrollPhysics(),
        overAndUnderCenterOpacity: 1.0,
        onSelectedItemChanged: (i) {
          int normalized = i % 60;
          if (normalized < 0) normalized += 60;
          setState(() => _minutes = normalized);
          _notifyChange();
        },
        childDelegate: ListWheelChildLoopingListDelegate(
          children: List.generate(60, (index) {
            int distance = (index - _minutes).abs();
            if (distance > 30) distance = 60 - distance;
            return WheelPickerChrome.wheelItem(
              context,
              index.toString().padLeft(2, '0'),
              distance,
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final display = WheelDurationPicker.format(_hours * 60 + _minutes);
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
              _colWidth,
              'picker_hour',
              _hourWheel(),
            ),
            WheelPickerChrome.separator(context),
            WheelPickerChrome.labeledColumn(
              context,
              _colWidth,
              'picker_minute',
              _minuteWheel(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        WheelPickerChrome.gradientPreview(context, display),
        if (widget.infoText != null) ...[
          const SizedBox(height: 20),
          WheelPickerChrome.infoPill(
            context,
            icon: Icons.timer_outlined,
            text: widget.infoText!.trParams({'args1': display}),
          ),
        ],
      ],
    );
  }
}

/// Bottom sheet wrapper around [WheelDurationPicker]. [title] is a
/// localization key describing what the duration is for.
void showWheelDurationPicker(
  BuildContext context, {
  required String title,
  required int initialMinutes,
  required ValueChanged<int> onSave,
  String? subtitle = 'interval_picker_hint',
  String? infoText = 'interval_pill_info',
  int minMinutes = 5,
}) {
  int selected = initialMinutes;
  PrimaryBottomSheet.show(
    context: context,
    title: title,
    buttonText: 'save',
    onButtonPressed: () {
      if (selected < minMinutes) {
        ToastUtils.showToast(context, 'interval_min_5'.tr);
        return;
      }
      Navigator.pop(context);
      onSave(selected);
    },
    content: WheelDurationPicker(
      initialMinutes: initialMinutes,
      onChanged: (m) => selected = m,
      subtitle: subtitle,
      infoText: infoText,
    ),
  );
}
