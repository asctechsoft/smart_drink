import 'dart:math' as math;

import 'package:dsp_base/app_material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartdrinkai/values/app_colors.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';

import 'history_section.dart';

class DayProgressCard extends StatelessWidget {
  const DayProgressCard({
    super.key,
    required this.totalLabel,
    required this.goalLabel,
    required this.unit,
    required this.progress,
    required this.dateLabel,
    required this.drinkCount,
    this.lastDrinkTime,
  });

  final String totalLabel;
  final String goalLabel;
  final String unit;
  final double progress;
  final String dateLabel;
  final int drinkCount;
  final String? lastDrinkTime;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final percent = (progress * 100).round();

    return HistoryCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'today'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ob.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            dateLabel,
            style: TextStyle(
              fontSize: 12,
              color: ob.textPrimary.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 14),
          IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _ProgressRing(
                      progress: progress,
                      totalLabel: totalLabel,
                      goalLabel: goalLabel,
                      unit: unit,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$percent% ${'goal'.tr}',
                      style: TextStyle(
                        fontSize: 12,
                        color: ob.textPrimary.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: ob.textPrimary.withValues(alpha: 0.15),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    _StatRow(
                      icon: Icons.water_drop_rounded,
                      label: 'total_volume'.tr,
                      value: '$totalLabel $unit',
                    ),
                    const SizedBox(height: 14),
                    _StatRow(
                      icon: Icons.local_drink_rounded,
                      label: 'drink_count'.tr,
                      value: '$drinkCount ${'unit_times'.tr}',
                    ),
                    const SizedBox(height: 14),
                    _StatRow(
                      icon: Icons.access_time_rounded,
                      label: 'last_drink'.tr,
                      value: lastDrinkTime ?? '--',
                    ),
                  ],
                ),
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

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: AppColors.primary500Dark),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: ob.textPrimary.withValues(alpha: 0.55),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary500Dark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.totalLabel,
    required this.goalLabel,
    required this.unit,
  });

  final double progress;
  final String totalLabel;
  final String goalLabel;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return SizedBox(
      width: 120,
      height: 120,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_drink_rounded,
                  size: 22,
                  color: AppColors.primary500Dark,
                ),
                const SizedBox(height: 4),
                Text(
                  totalLabel,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: ob.textPrimary,
                  ),
                ),
                Text(
                  '/ $goalLabel $unit',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: ob.textPrimary.withValues(alpha: 0.65),
                  ),
                ),
              ],
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
    const stroke = 8.0;
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
