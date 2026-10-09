import 'package:asc_common/asc_common.dart';
import 'package:flutter/material.dart';

/// App-wide toggle switch: [AppSwitch] in the app's mint→cyan brand gradient.
///
/// [activeColor]/[trackColor] are kept for call-site compatibility; the
/// gradient/track follow the shared design regardless of the values passed.
class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color trackColor;
  final double width;
  final double height;
  final double padding;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.activeColor,
    required this.trackColor,
    this.width = 42,
    this.height = 24,
    this.padding = 3,
  });

  static const Color _onStart = Color(0xFF59D893); // mint
  static const Color _onEnd = Color(0xFF29C5C9); // cyan
  static const Color _offTrack = Color.fromARGB(255, 211, 216, 223);

  @override
  Widget build(BuildContext context) => AppSwitch(
    value: value,
    onChanged: onChanged,
    activeColors: const [_onStart, _onEnd],
    inactiveColor: _offTrack,
    width: width,
    height: height,
    padding: padding,
  );
}
