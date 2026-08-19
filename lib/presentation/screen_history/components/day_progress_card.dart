import 'dart:math' as math;

import 'package:dsp_base/app_material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartdrinkai/values/app_colors.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';

import 'history_section.dart';

/// Day tab hero: a progress ring beside "400 / 1850 ml" and the percentage.
class DayProgressCard extends StatelessWidget {
  const DayProgressCard({
    super.key,
    required this.totalLabel,
    required this.goalLabel,
    required this.unit,
    required this.progress,
  });

  final String totalLabel;
  final String goalLabel;
  final String unit;

  /// 0..1, already clamped by the caller if it can exceed the goal.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final percent = (progress * 100).round();

    return HistoryCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Row(
        children: [
          _ProgressRing(progress: progress),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: totalLabel,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: ob.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: ' / $goalLabel $unit',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: ob.textPrimary.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${'completed'.tr} ',
                        style: TextStyle(
                          fontSize: 13,
                          color: ob.textPrimary.withValues(alpha: 0.65),
                        ),
                      ),
                      TextSpan(
                        text: '$percent%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary500Dark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return SizedBox(
      width: 84,
      height: 84,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: progress),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => CustomPaint(
          painter: _RingPainter(
            progress: value,
            trackColor: ob.textPrimary.withValues(alpha: 0.12),
          ),
          child: Center(
            child: Icon(
              Icons.water_drop_rounded,
              size: 34,
              color: AppColors.primary500Dark,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.trackColor});

  final double progress;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 7.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) - stroke) / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [AppColors.accentTeal, AppColors.primary500Dark],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0.0, 1.0),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.trackColor != trackColor;
}
