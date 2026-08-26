import 'package:dsp_base/app_material.dart';
import 'package:waternudge/values/app_colors.dart';

/// Vertical ruler picker: a big value header above a scrollable ruler.
///
/// Horizontal layout, left to right: right-aligned number, major dash, the rail
/// (a static vertical line on the component's centre line), then a dense tick
/// ladder. A glowing dot rides the rail on the selected value, and the light
/// beam through it is split into two segments so it never crosses the number.
class RulerPicker extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int initialValue;
  final String unit;
  final ValueChanged<int> onChanged;
  final double rulerHeight;

  /// Formats a scale value for display. The scale itself stays integer so the
  /// wheel keeps a fixed step (e.g. centimetres shown as "1.70" in metres).
  final String Function(int)? labelBuilder;

  const RulerPicker({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.initialValue,
    required this.unit,
    required this.onChanged,
    this.rulerHeight = 300,
    this.labelBuilder,
  });

  @override
  State<RulerPicker> createState() => _RulerPickerState();
}

class _RulerPickerState extends State<RulerPicker> {
  // Widths of one ruler row, left to right. Kept narrow enough that the beam's
  // gap hugs the number instead of leaving a wide blank.
  static const double _labelWidth = 46;
  static const double _labelGap = 10;
  static const double _dashWidth = 16;
  static const double _dashGap = 10;
  static const double _railWidth = 2;
  static const double _tickGap = 6;
  static const double _tickWidth = 16;

  /// Distance from a row's left edge to the rail.
  static const double _railLeft =
      _labelWidth + _labelGap + _dashWidth + _dashGap;
  static const double _rowWidth =
      _railLeft + _railWidth + _tickGap + _tickWidth;

  static const double _itemExtent = 42;
  static const double _dotSize = 20;

  /// Minor ticks drawn per whole value, alongside the rail.
  static const int _ticksPerStep = 4;

  static const Color _railColor = Color(0xFFBFEFFF);
  static const Color _dotCore = Color(0xFF5FD9FF);

  late FixedExtentScrollController _controller;
  late int _selectedIndex;

  int get _itemCount => widget.maxValue - widget.minValue + 1;

  /// The scale runs top-down from [RulerPicker.maxValue], like a real ruler, so
  /// index 0 is the largest value.
  int _valueAt(int index) => widget.maxValue - index;

  int _indexOf(int value) => widget.maxValue - value;

  int get _selectedValue => _valueAt(_selectedIndex);

  @override
  void initState() {
    super.initState();
    final clamped = widget.initialValue.clamp(widget.minValue, widget.maxValue);
    _selectedIndex = _indexOf(clamped);
    _controller = FixedExtentScrollController(initialItem: _selectedIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Left edge of a row so that the rail lands on the component's centre line.
  double _rowLeft(double maxWidth) =>
      (maxWidth / 2 - _railLeft).clamp(0.0, double.infinity);

  @override
  Widget build(BuildContext context) {
    return AppColumn(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildValueHeader(),
        AppSpacerH16,
        SizedBox(
          height: widget.rulerHeight,
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final rowLeft = _rowLeft(maxWidth);
              return Stack(
                children: [
                  _buildRail(rowLeft),
                  _buildWheel(rowLeft),
                  _buildMarker(maxWidth, rowLeft),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildValueHeader() {
    final value = _selectedValue;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        AppText(
          widget.labelBuilder?.call(value) ?? '$value',
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w700,
            color: AppColors.basic500,
            letterSpacing: 0.5,
          ),
        ),
        AppSpacerW6,
        AppText(
          widget.unit,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.basic500.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildRail(double rowLeft) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: rowLeft + _railLeft,
      width: _railWidth,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _railColor.withValues(alpha: 0),
                _railColor.withValues(alpha: 0.85),
                _railColor.withValues(alpha: 0.85),
                _railColor.withValues(alpha: 0),
              ],
              stops: const [0, 0.07, 0.93, 1],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWheel(double rowLeft) {
    return ListWheelScrollView.useDelegate(
      controller: _controller,
      itemExtent: _itemExtent,
      diameterRatio: 2.2,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: (index) {
        setState(() => _selectedIndex = index);
        widget.onChanged(_valueAt(index));
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: _itemCount,
        builder: (context, index) {
          if (index < 0 || index >= _itemCount) return null;
          return _buildRow(_valueAt(index), index == _selectedIndex, rowLeft);
        },
      ),
    );
  }

  Widget _buildRow(int value, bool isSelected, double rowLeft) {
    final distance = (value - _selectedValue).abs();
    double alpha;
    if (isSelected) {
      alpha = 1;
    } else if (distance == 1) {
      alpha = 0.85;
    } else if (distance == 2) {
      alpha = 0.7;
    } else if (distance == 3) {
      alpha = 0.55;
    } else {
      alpha = 0.4;
    }
    final color = AppColors.basic500.withValues(alpha: alpha);

    return Stack(
      children: [
        Positioned(
          left: rowLeft,
          top: 0,
          bottom: 0,
          width: _rowWidth,
          child: Row(
            children: [
              SizedBox(
                width: _labelWidth,
                child: AppText(
                  widget.labelBuilder?.call(value) ?? '$value',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: isSelected ? 21 : 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: _labelGap),
              SizedBox(
                width: _dashWidth,
                child: Center(
                  child: Container(
                    width: _dashWidth,
                    height: isSelected ? 2.5 : 1.5,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: _dashGap + _railWidth + _tickGap),
              SizedBox(
                width: _tickWidth,
                height: _itemExtent,
                child: CustomPaint(
                  painter: _MinorTicksPainter(
                    color: color,
                    count: _ticksPerStep,
                    isSelected: isSelected,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Two beam segments plus the dot. The gap between the segments is the label
  /// box, so the beam stops at the number instead of striking through it.
  Widget _buildMarker(double maxWidth, double rowLeft) {
    final beamRightLeft = rowLeft + _labelWidth + _labelGap;
    return IgnorePointer(
      child: Stack(
        children: [
          if (rowLeft > 0)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: rowLeft,
              child: Center(child: _beam(brightAtEnd: true)),
            ),
          Positioned(
            left: beamRightLeft,
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(child: _beam(brightAtEnd: false)),
          ),
          Positioned(
            left: rowLeft + _railLeft + _railWidth / 2 - _dotSize / 2,
            top: 0,
            bottom: 0,
            width: _dotSize,
            child: Center(child: _dot()),
          ),
        ],
      ),
    );
  }

  /// A 2px light beam. [brightAtEnd] puts the bright end on the right, which is
  /// the end that meets the number.
  Widget _beam({required bool brightAtEnd}) {
    final colors = [
      AppColors.basic500.withValues(alpha: 0),
      AppColors.basic500.withValues(alpha: 0.95),
    ];
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: brightAtEnd ? colors : colors.reversed.toList(),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.basic500.withValues(alpha: 0.45),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }

  Widget _dot() {
    return Container(
      width: _dotSize,
      height: _dotSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.basic500,
        boxShadow: [
          BoxShadow(
            color: _dotCore.withValues(alpha: 0.9),
            blurRadius: 18,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: _dotSize / 2,
          height: _dotSize / 2,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: _dotCore,
          ),
        ),
      ),
    );
  }
}

/// Draws the dense tick ladder that runs alongside the rail. Ticks sit at even
/// fractions of the row so consecutive rows form one continuous ladder.
class _MinorTicksPainter extends CustomPainter {
  final Color color;
  final int count;
  final bool isSelected;

  _MinorTicksPainter({
    required this.color,
    required this.count,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var i = 0; i < count; i++) {
      final y = i / count * size.height;
      // The tick level with the number (row centre) is the long one.
      final isMajor = i == count ~/ 2;
      final width = isMajor ? size.width : size.width * 0.5;
      final height = isMajor && isSelected ? 2.5 : 1.2;
      canvas.drawRect(Rect.fromLTWH(0, y - height / 2, width, height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MinorTicksPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.count != count ||
      oldDelegate.isSelected != isSelected;
}
