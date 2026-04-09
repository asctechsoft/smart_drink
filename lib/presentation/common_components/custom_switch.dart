import 'package:flutter/material.dart';

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
    this.width = 40, // Longer aspect ratio
    this.height = 20,
    this.padding = 2, // 2px margin from edge
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: 'Toggle switch',
      onTap: () => onChanged(!value),
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            color: value ? activeColor : trackColor,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 0.5,
            ),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Container(
                width: height - (padding * 2) - 1, // -1 for border adjustment
                height: height - (padding * 2) - 1,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

