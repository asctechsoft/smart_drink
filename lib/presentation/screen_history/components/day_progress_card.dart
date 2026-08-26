import 'dart:math' as math;

import 'package:dsp_base/app_material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:waternudge/values/app_colors.dart';
import 'package:waternudge/values/onboarding_theme.dart';

import 'history_section.dart';

/// Stat icon tint, matching the settings screen + month/year summary icons.
const Color _statIconColor = Color(0xFF96D2A8);

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
                      icon: SvgPicture.asset(
                        'assets/images/svg/ic_cup_water_bar.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          _statIconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: 'total_volume'.tr,
                      value: '$totalLabel $unit',
                    ),
                    const SizedBox(height: 14),
                    _StatRow(
                      icon: const Icon(
                        Icons.local_drink_rounded,
                        size: 20,
                        color: _statIconColor,
                      ),
                      label: 'drink_count'.tr,
                      value: '$drinkCount ${'unit_times'.tr}',
                    ),
                    const SizedBox(height: 14),
                    _StatRow(
                      icon: const Icon(
                        Icons.access_time_rounded,
                        size: 20,
                        color: _statIconColor,
                      ),
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

  final Widget icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 20, height: 20, child: icon),
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
      // Match the daily-goal bottom-sheet ring gradient.
      ..shader = SweepGradient(
        colors: const [
          Color(0xFF50D1F0),
          Color(0xFF1E69FF),
          Color(0xFF50D1F0),
        ],
        stops: const [0.0, 0.5, 1.0],
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + math.pi * 2,
        transform: const GradientRotation(-math.pi / 2),
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
