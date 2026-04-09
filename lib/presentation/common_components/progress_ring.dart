import 'dart:math';
import 'dart:ui' as ui;
import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/utils/unit_converter.dart';
import 'package:smartdrinkai/values/app_colors.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';

class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int currentMl;
  final int goalMl;
  final String volumeUnit;
  final double size;
  final double textScale;
  final bool isWidget;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.currentMl,
    required this.goalMl,
    this.volumeUnit = 'ml',
    this.size = 300,
    this.textScale = 1.0,
    this.isWidget = false,
  });

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: progress),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, animProgress, child) {
        // Tính tỷ lệ currentMl theo progress của animation để số nhảy mượt mà theo vòng cung
        final int displayMl = progress > 0
            ? (currentMl * (animProgress / progress)).toInt()
            : 0;

        return SizedBox(
          width: size,
          height: size + 8,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Ring arc
              SizedBox(
                width: size,
                height: size,
                child: Semantics(
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(isRtl ? pi : 0),
                    child: CustomPaint(
                      painter: _ProgressRingPainter(progress: animProgress),
                    ),
                  ),
                ),
              ),
              // Water drop icon centered
              AppIcon('assets/images/webp/img_water.webp', size: size),

              // Current ml + goal text at bottom
              Positioned(
                left: 0,
                right: 0,
                top: size * 0.76,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      UnitConverter.formatVolumeValue(
                        displayMl.toDouble(),
                        volumeUnit,
                      ),
                      style: TextStyle(
                        fontSize: 40 * textScale,
                        fontWeight: FontWeight.w600,
                        color: isWidget ? AppColors.basic500 : ob.textPrimary,
                        letterSpacing: 2,
                        height: 1.2,
                      ),
                    ),
                    AppRow(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          '/ ',
                          style: TextStyle(
                            fontSize: 18 * textScale,
                            fontWeight: FontWeight.w500,
                            color: isWidget
                                ? AppColors.basic300
                                : ob.textrReminderCountdown,
                            letterSpacing: 0.7,
                          ),
                        ),
                        AppText(
                          UnitConverter.formatVolume(
                            goalMl.toDouble(),
                            volumeUnit,
                          ),
                          style: TextStyle(
                            fontSize: 18 * textScale,
                            fontWeight: FontWeight.w500,
                            color: isWidget
                                ? AppColors.basic300
                                : ob.textrReminderCountdown,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;

  _ProgressRingPainter({required this.progress});

  // 270° arc with gap at bottom
  static const double _startAngle = 135 * (pi / 180);
  static const double _totalSweep = 270 * (pi / 180);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 18.0;
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track Drop Shadow
    final trackGlowPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          strokeWidth // Vẽ dày hơn 24px để shadow lòi ra cả 2 bên (mỗi bên 12px)
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawArc(rect, _startAngle, _totalSweep, false, trackGlowPaint);

    // Background track (Màu tối thay vì trắng mờ)
    final trackPaint = Paint()
      ..color = const Color(0xFF021447)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _startAngle, _totalSweep, false, trackPaint);

    // Progress arc with gradient & glow
    if (progress > 0) {
      final sweepAngle = _totalSweep * progress.clamp(0.0, 1.0);

      final gradient = SweepGradient(
        startAngle: 0,
        endAngle: pi * 2,
        colors: const [Color(0xFF00E0FF), Color(0xFF0094FF), Color(0xFF00E0FF)],
        stops: [
          0,
          _totalSweep / (pi * 2), // Điểm 270 độ (cuối thanh tiến trình)
          1, // Trở về mức màu ban đầu để nắp bo tròn (cap) đầu tiên không bị gãy màu
        ],
        transform: GradientRotation(_startAngle),
      );

      // Progress Shadow/Glow
      // final progressGlowPaint = Paint()
      //   ..shader = gradient.createShader(rect)
      //   ..style = PaintingStyle.stroke
      //   ..strokeWidth = strokeWidth
      //   ..strokeCap = StrokeCap.round
      //   ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      // canvas.drawArc(rect, _startAngle, sweepAngle, false, progressGlowPaint);

      // Main Progress
      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, _startAngle, sweepAngle, false, progressPaint);

      // Glow at the end (Tip) of progress arc
      if (progress > 0.02) {
        final endAngle = _startAngle + sweepAngle;
        final endX = center.dx + radius * cos(endAngle);
        final endY = center.dy + radius * sin(endAngle);

        // Quầng sáng to mờ
        final tipGlowPaint = Paint()
          ..shader = ui.Gradient.radial(Offset(endX, endY), 12, [
            const Color(0xFF00E0FF).withValues(alpha: 0.8),
            const Color(0xFF00E0FF).withValues(alpha: 0.0),
          ])
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(endX, endY), 0, tipGlowPaint);

        // Core sáng
        final tipCorePaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.6)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
        canvas.drawCircle(Offset(endX, endY), 4, tipCorePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

