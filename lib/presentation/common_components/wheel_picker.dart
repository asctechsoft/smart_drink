import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';

class WheelPicker extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int initialValue;
  final ValueChanged<int> onChanged;
  final String? suffix;
  final String Function(int)? labelBuilder;
  final bool showIndicator;
  final Color? textColor;
  final Color? suffixColor;
  final double itemWidth;
  final bool isLooping;
  final int visibleItemCount;
  final Color? colorBorder;
  final int step;

  const WheelPicker({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.initialValue,
    required this.onChanged,
    this.suffix,
    this.labelBuilder,
    this.showIndicator = false,
    this.textColor,
    this.suffixColor,
    this.itemWidth = 90,
    this.isLooping = false,
    this.visibleItemCount = 5,
    this.colorBorder,
    this.step = 1,
  });

  @override
  State<WheelPicker> createState() => _WheelPickerState();
}

class _WheelPickerState extends State<WheelPicker> {
  late FixedExtentScrollController _controller;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    final clamped = widget.initialValue.clamp(widget.minValue, widget.maxValue);
    _selectedIndex = ((clamped - widget.minValue) / widget.step).round();
    _controller = FixedExtentScrollController(initialItem: _selectedIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final color = ob.textPrimary;

    return SizedBox(
      height: widget.visibleItemCount * 60.0,
      child: Stack(
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
              // Left side: Indicator arrow
              Expanded(
                child: widget.showIndicator
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 50),
                          child: AppIcon(
                            'assets/images/webp/ic_arrow_left.webp',
                            size: 40,
                            autoMirror: true,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              // Center: The scrollable values
              SizedBox(
                width: widget.itemWidth,
                child: ListWheelScrollView.useDelegate(
                  controller: _controller,
                  itemExtent: 60,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() => _selectedIndex = index);
                    if (widget.isLooping) {
                      final count =
                          ((widget.maxValue - widget.minValue) / widget.step)
                              .floor() +
                          1;
                      int normalized = index % count;
                      if (normalized < 0) normalized += count;
                      widget.onChanged(
                        widget.minValue + normalized * widget.step,
                      );
                    } else {
                      widget.onChanged(widget.minValue + index * widget.step);
                    }
                  },
                  childDelegate: widget.isLooping
                      ? ListWheelChildLoopingListDelegate(
                          children: List.generate(
                            ((widget.maxValue - widget.minValue) / widget.step)
                                    .floor() +
                                1,
                            (idx) {
                              final value = widget.minValue + idx * widget.step;
                              final label =
                                  widget.labelBuilder?.call(value) ?? '$value';
                              final count =
                                  ((widget.maxValue - widget.minValue) /
                                          widget.step)
                                      .floor() +
                                  1;

                              int normalizedSelectedIndex =
                                  _selectedIndex % count;
                              if (normalizedSelectedIndex < 0) {
                                normalizedSelectedIndex += count;
                              }

                              int distance = (idx - normalizedSelectedIndex)
                                  .abs();
                              if (distance > count / 2) {
                                distance = count - distance;
                              }

                              final isSelected = distance == 0;

                              Color itemColor = color;
                              if (distance == 1) {
                                itemColor = color.withValues(alpha: 0.5);
                              } else if (distance >= 2) {
                                itemColor = color.withValues(alpha: 0.1);
                              }

                              return Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: AppText(
                                    label,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: isSelected ? 32 : 18,
                                      fontWeight: FontWeight.w600,
                                      color: itemColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            final value = widget.minValue + index * widget.step;
                            if (value > widget.maxValue ||
                                value < widget.minValue) {
                              return null;
                            }
                            final label =
                                widget.labelBuilder?.call(value) ?? '$value';
                            final isSelected = index == _selectedIndex;

                            final distance = (index - _selectedIndex).abs();
                            Color itemColor = color;
                            if (distance == 1) {
                              itemColor = color.withValues(alpha: 0.5);
                            } else if (distance >= 2) {
                              itemColor = color.withValues(alpha: 0.1);
                            }

                            return Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: AppText(
                                  label,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: isSelected ? 32 : 18,
                                    fontWeight: FontWeight.w600,
                                    color: itemColor,
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount:
                              ((widget.maxValue - widget.minValue) /
                                      widget.step)
                                  .floor() +
                              1,
                        ),
                ),
              ),
              // Right side: Suffix (unit)
              Expanded(
                child: widget.suffix != null
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 50),
                          child: AppText(
                            widget.suffix!,
                            style: TextStyle(
                              fontSize: 24,
                              color: ob.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

