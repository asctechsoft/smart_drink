import 'package:flutter/material.dart';

/// App-wide toggle switch. ON = mint→cyan gradient with a soft glow, OFF =
/// light track; white knob floats with a drop shadow.
///
/// [activeColor]/[trackColor] are kept for call-site compatibility but the
/// gradient/track now follow the shared design regardless of the values passed.
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

  // Shared design tokens.
  static const Color _onStart = Color(0xFF59D893); // mint
  static const Color _onEnd = Color(0xFF29C5C9); // cyan
  static const Color _offTrack = Color.fromARGB(255, 211, 216, 223);

  @override
  Widget build(BuildContext context) {
    final knob = height - (padding * 2);
    return Semantics(
      toggled: value,
      label: 'Toggle switch',
      onTap: () => onChanged(!value),
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          width: width,
          height: height,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            // Always a gradient (OFF = solid-colour gradient) so AnimatedContainer
            // tweens gradient→gradient smoothly instead of flickering on the
            // gradient↔color decoration swap.
            gradient: value
                ? const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [_onStart, _onEnd],
                  )
                : const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [_offTrack, _offTrack],
                  ),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: knob,
              height: knob,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
