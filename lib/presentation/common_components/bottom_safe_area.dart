import 'package:dsp_base/app_material.dart';
import 'package:flutter/material.dart';

class BottomSafeArea extends StatelessWidget {
  const BottomSafeArea({super.key, this.color = Colors.transparent});
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    return Container(
      width: double.infinity,
      height: bottomPadding,
      color: color,
    );
  }
}

