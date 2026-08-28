import 'package:dsp_base/app_material.dart';
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
  // The picker always works in 24h. Display formatting elsewhere follows the
  // device setting; there is no AM/PM selector.
  late int _hour;
  late int _minute;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late int _selectedHourIndex;
  late int _selectedMinuteIndex;

  @override
  void initState() {
    super.initState();
    final parts = widget.initialTime.split(':');
    _hour = int.tryParse(parts[0]) ?? 7;
    _minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    _selectedHourIndex = _hour;
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
    super.dispose();
  }

  void _notifyChange() {
    final result =
        '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';
    widget.onChanged(result);
  }

  String _two(int i) => i.toString().padLeft(2, '0');

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
    final double selectedSize = widget.enhanced ? 24 : 32;
    final double unselectedSize = widget.enhanced ? 13 : 16;

    Widget itemFor(int index, int selected) {
      int distance = (index - selected).abs();
      if (isLooping) {
        final half = itemCount ~/ 2;
        if (distance > half) distance = itemCount - distance;
      }
      final isSelected = distance == 0;
      Color itemColor = ob.textPrimary;
      if (distance == 1) {
        itemColor = ob.textPrimary.withValues(alpha: 0.5);
      } else if (distance >= 2) {
        itemColor = ob.textPrimary.withValues(alpha: 0.1);
      }
      return Center(
        child: AppText(
          labelBuilder(index),
          style: TextStyle(
            fontSize: isSelected ? selectedSize : unselectedSize,
            fontWeight: FontWeight.w600,
            color: itemColor,
          ),
        ),
      );
    }

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

  /// Wheel wrapped with a glowing selection box centered behind it.
  Widget _glowSlot(double width, Widget wheel) {
    final ob = OnboardingTheme.of(context);
    return SizedBox(
      width: width,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(
            child: Container(
              width: width,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ob.textAccent, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: ob.textAccent.withValues(alpha: 0.5),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          wheel,
        ],
      ),
    );
  }

  Widget _columnHeader(double width, String key) {
    final ob = OnboardingTheme.of(context);
    return SizedBox(
      width: width,
      child: Center(
        child: AppText(
          key.tr,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: ob.textAccent,
          ),
        ),
      ),
    );
  }

  Widget _bigPreview() {
    final ob = OnboardingTheme.of(context);
    final display = '${_two(_hour)}:${_two(_minute)}';
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [ob.buttonStart, ob.buttonEnd],
      ).createShader(bounds),
      child: Text(
        display,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _infoPill(String key) {
    final ob = OnboardingTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ob.textAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ob.textAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bedtime_rounded, size: 20, color: ob.textAccent),
          const SizedBox(width: 10),
          Flexible(
            child: AppText(
              key.tr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ob.textPrimary.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final double hourW = widget.enhanced ? 96 : 60;
    final double minW = widget.enhanced ? 96 : 60;

    Widget hourWheel = _buildWheel(
      controller: _hourController,
      itemCount: 24,
      labelBuilder: _two,
      selectedIndex: _selectedHourIndex,
      width: hourW,
      onChanged: (i) {
        setState(() {
          _selectedHourIndex = i;
          _hour = i;
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

    final Widget separator = Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.enhanced ? 10 : 4),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: widget.enhanced ? 16 : 24,
          fontWeight: FontWeight.w700,
          color: ob.textPrimary,
        ),
      ),
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
            children: [hourWheel, separator, minuteWheel],
          ),
        ],
      );
    }

    // Enhanced layout: each column stacks its header over its wheel so labels
    // stay aligned; the ":" is nudged down to the wheel's centre band.
    Widget labeledColumn(double width, String headerKey, Widget wheel) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _columnHeader(width, headerKey),
          const SizedBox(height: 6),
          _glowSlot(width, wheel),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.subtitle != null) ...[
          AppText(
            widget.subtitle!.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: ob.textSubtitle,
            ),
          ),
          const SizedBox(height: 20),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            labeledColumn(hourW, 'picker_hour', hourWheel),
            // header (~20) + gap (6) + half wheel (100) - half glyph.
            Padding(padding: const EdgeInsets.only(top: 116), child: separator),
            labeledColumn(minW, 'picker_minute', minuteWheel),
          ],
        ),
        const SizedBox(height: 8),
        _bigPreview(),
        if (widget.infoText != null) ...[
          const SizedBox(height: 20),
          _infoPill(widget.infoText!),
        ],
      ],
    );
  }
}
