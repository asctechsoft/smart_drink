import 'dart:math';
import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/utils/unit_converter.dart';
import 'package:smartdrinkai/values/app_colors.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';

class HumanBodyProgress extends StatefulWidget {
  final double progress;
  final int currentMl;
  final int goalMl;
  final String volumeUnit;
  final double width;
  final double height;

  const HumanBodyProgress({
    super.key,
    required this.progress,
    required this.currentMl,
    required this.goalMl,
    this.volumeUnit = 'ml',
    this.width = 180,
    this.height = 290,
  });

  @override
  State<HumanBodyProgress> createState() => _HumanBodyProgressState();
}

class _HumanBodyProgressState extends State<HumanBodyProgress>
    with TickerProviderStateMixin {
  late final AnimationController _waveController;
  late AnimationController _fillController;
  late Animation<double> _fillAnim;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fillAnim = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _fillController, curve: Curves.easeOutCubic),
    );
    _fillController.forward();
  }

  @override
  void didUpdateWidget(HumanBodyProgress old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _fillAnim = Tween<double>(
        begin: _fillAnim.value,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _fillController, curve: Curves.easeOutCubic),
      );
      _fillController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return AnimatedBuilder(
      animation: Listenable.merge([_waveController, _fillController]),
      builder: (context, _) {
        final animProgress = _fillAnim.value;
        final displayMl = widget.progress > 0
            ? (widget.currentMl * (animProgress / widget.progress)).toInt()
            : 0;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: widget.width,
              height: widget.height,
              child: CustomPaint(
                painter: _HumanBodyPainter(
                  progress: animProgress,
                  wavePhase: _waveController.value * 2 * pi,
                  isLight: ob.isLight,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              UnitConverter.formatVolumeValue(
                displayMl.toDouble(),
                widget.volumeUnit,
              ),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w600,
                color: ob.textPrimary,
                letterSpacing: 2,
                height: 1.2,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '/ ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: ob.textrReminderCountdown,
                    letterSpacing: 0.7,
                  ),
                ),
                Text(
                  UnitConverter.formatVolume(
                    widget.goalMl.toDouble(),
                    widget.volumeUnit,
                  ),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: ob.textrReminderCountdown,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _HumanBodyPainter extends CustomPainter {
  final double progress;
  final double wavePhase;
  final bool isLight;

  const _HumanBodyPainter({
    required this.progress,
    required this.wavePhase,
    required this.isLight,
  });

  /// Builds the complete human silhouette as ONE continuous closed path,
  /// traced clockwise starting at the top of the head.
  ///
  /// Layout (fractions of canvas w × h):
  ///   Head centre : (0.50, 0.070)  oval ~0.28w × 0.125h
  ///   Neck        : ~0.10w wide, h 0.132→0.170
  ///   Shoulders   : 0.17w … 0.83w  at h ≈ 0.185
  ///   Arms        : outer ~0.09w / inner ~0.28w, wrist at h ≈ 0.57, hand bottom h ≈ 0.68
  ///   Waist       : 0.34w … 0.66w  at h ≈ 0.50
  ///   Hips        : 0.30w … 0.70w  at h ≈ 0.62
  ///   Legs        : left [0.30,0.46] / right [0.54,0.70], crotch h ≈ 0.645
  ///   Feet        : slightly wider, flat bottom at h ≈ 0.978
  Path _buildBodyPath(Size size) {
    final w = size.width;
    final h = size.height;
    final p = Path();

    // ═══════════════════════════════════════════════════════════════════════
    // HEAD  – top of head, trace right half then continue clockwise
    // ═══════════════════════════════════════════════════════════════════════
    p.moveTo(w * 0.500, h * 0.008); // top-centre of head

    // right head arc
    p.cubicTo(
      w * 0.636, h * 0.007,
      w * 0.658, h * 0.124,
      w * 0.565, h * 0.138,
    );

    // ── right neck ──────────────────────────────────────────────────────────
    p.cubicTo(
      w * 0.554, h * 0.146,
      w * 0.547, h * 0.158,
      w * 0.547, h * 0.172,
    );

    // ── right shoulder sweeping out ──────────────────────────────────────────
    p.cubicTo(
      w * 0.560, h * 0.172,
      w * 0.800, h * 0.178,
      w * 0.820, h * 0.214,
    );

    // ── right arm outer edge going down ─────────────────────────────────────
    p.cubicTo(
      w * 0.840, h * 0.250,
      w * 0.852, h * 0.370,
      w * 0.848, h * 0.480,
    );
    p.lineTo(w * 0.844, h * 0.562);

    // ── right hand: outer curve → bottom → inner side ───────────────────────
    p.cubicTo(
      w * 0.846, h * 0.590,
      w * 0.852, h * 0.624,
      w * 0.848, h * 0.648,
    ); // outer hand
    p.cubicTo(
      w * 0.844, h * 0.666,
      w * 0.830, h * 0.676,
      w * 0.810, h * 0.674,
    ); // hand bottom
    p.cubicTo(
      w * 0.790, h * 0.672,
      w * 0.776, h * 0.660,
      w * 0.773, h * 0.638,
    ); // inner hand

    // ── right arm inner going up ─────────────────────────────────────────────
    p.cubicTo(
      w * 0.770, h * 0.614,
      w * 0.766, h * 0.578,
      w * 0.765, h * 0.542,
    );
    p.lineTo(w * 0.765, h * 0.415);
    p.cubicTo(
      w * 0.765, h * 0.308,
      w * 0.758, h * 0.238,
      w * 0.752, h * 0.206,
    );
    p.cubicTo(
      w * 0.746, h * 0.190,
      w * 0.734, h * 0.184,
      w * 0.720, h * 0.184,
    );

    // ── right underarm → right body side (chest/waist/hip) ──────────────────
    p.cubicTo(
      w * 0.706, h * 0.184,
      w * 0.696, h * 0.198,
      w * 0.690, h * 0.222,
    );
    p.cubicTo(
      w * 0.678, h * 0.268,
      w * 0.666, h * 0.372,
      w * 0.670, h * 0.445,
    ); // chest
    p.cubicTo(
      w * 0.671, h * 0.485,
      w * 0.666, h * 0.516,
      w * 0.670, h * 0.550,
    ); // waist
    p.cubicTo(
      w * 0.676, h * 0.582,
      w * 0.688, h * 0.602,
      w * 0.698, h * 0.618,
    ); // hip flare

    // ── right leg outer ──────────────────────────────────────────────────────
    p.cubicTo(
      w * 0.708, h * 0.638,
      w * 0.714, h * 0.660,
      w * 0.714, h * 0.686,
    );
    p.lineTo(w * 0.714, h * 0.868);

    // ── right foot ───────────────────────────────────────────────────────────
    p.cubicTo(
      w * 0.714, h * 0.906,
      w * 0.716, h * 0.934,
      w * 0.720, h * 0.950,
    );
    p.cubicTo(
      w * 0.726, h * 0.968,
      w * 0.738, h * 0.976,
      w * 0.754, h * 0.978,
    );
    p.lineTo(w * 0.808, h * 0.978); // foot extends slightly right
    p.cubicTo(
      w * 0.824, h * 0.978,
      w * 0.834, h * 0.970,
      w * 0.838, h * 0.956,
    );
    p.cubicTo(
      w * 0.842, h * 0.940,
      w * 0.842, h * 0.914,
      w * 0.842, h * 0.880,
    );

    // ── right leg inner going up to crotch ───────────────────────────────────
    p.lineTo(w * 0.842, h * 0.690);
    p.cubicTo(
      w * 0.842, h * 0.664,
      w * 0.836, h * 0.648,
      w * 0.824, h * 0.644,
    );
    p.cubicTo(
      w * 0.812, h * 0.640,
      w * 0.798, h * 0.644,
      w * 0.790, h * 0.658,
    );
    p.lineTo(w * 0.782, h * 0.688);
    p.cubicTo(
      w * 0.780, h * 0.712,
      w * 0.770, h * 0.732,
      w * 0.754, h * 0.742,
    );
    p.cubicTo(
      w * 0.734, h * 0.752,
      w * 0.706, h * 0.750,
      w * 0.680, h * 0.740,
    );

    // ── crotch ───────────────────────────────────────────────────────────────
    p.cubicTo(
      w * 0.570, h * 0.720,
      w * 0.545, h * 0.742,
      w * 0.500, h * 0.748,
    );
    p.cubicTo(
      w * 0.455, h * 0.742,
      w * 0.430, h * 0.720,
      w * 0.320, h * 0.740,
    );

    // ── left leg inner going down ─────────────────────────────────────────────
    p.cubicTo(
      w * 0.294, h * 0.750,
      w * 0.266, h * 0.752,
      w * 0.246, h * 0.742,
    );
    p.cubicTo(
      w * 0.230, h * 0.732,
      w * 0.220, h * 0.712,
      w * 0.218, h * 0.688,
    );
    p.lineTo(w * 0.210, h * 0.658);
    p.cubicTo(
      w * 0.202, h * 0.644,
      w * 0.188, h * 0.640,
      w * 0.176, h * 0.644,
    );
    p.cubicTo(
      w * 0.164, h * 0.648,
      w * 0.158, h * 0.664,
      w * 0.158, h * 0.690,
    );
    p.lineTo(w * 0.158, h * 0.880);
    p.cubicTo(
      w * 0.158, h * 0.914,
      w * 0.158, h * 0.940,
      w * 0.162, h * 0.956,
    );
    p.cubicTo(
      w * 0.166, h * 0.970,
      w * 0.176, h * 0.978,
      w * 0.192, h * 0.978,
    );
    p.lineTo(w * 0.246, h * 0.978); // left foot extends slightly left
    p.cubicTo(
      w * 0.262, h * 0.976,
      w * 0.274, h * 0.968,
      w * 0.280, h * 0.950,
    );
    p.cubicTo(
      w * 0.284, h * 0.934,
      w * 0.286, h * 0.906,
      w * 0.286, h * 0.868,
    );
    p.lineTo(w * 0.286, h * 0.686);

    // ── left leg outer going up ───────────────────────────────────────────────
    p.cubicTo(
      w * 0.286, h * 0.660,
      w * 0.292, h * 0.638,
      w * 0.302, h * 0.618,
    );

    // ── left hip / waist / body side going up ─────────────────────────────────
    p.cubicTo(
      w * 0.312, h * 0.602,
      w * 0.324, h * 0.582,
      w * 0.330, h * 0.550,
    );
    p.cubicTo(
      w * 0.334, h * 0.516,
      w * 0.329, h * 0.485,
      w * 0.330, h * 0.445,
    ); // waist
    p.cubicTo(
      w * 0.334, h * 0.372,
      w * 0.322, h * 0.268,
      w * 0.310, h * 0.222,
    ); // chest
    p.cubicTo(
      w * 0.304, h * 0.198,
      w * 0.294, h * 0.184,
      w * 0.280, h * 0.184,
    );
    p.cubicTo(
      w * 0.266, h * 0.184,
      w * 0.254, h * 0.190,
      w * 0.248, h * 0.206,
    );
    p.cubicTo(
      w * 0.242, h * 0.238,
      w * 0.235, h * 0.308,
      w * 0.235, h * 0.415,
    );
    p.lineTo(w * 0.235, h * 0.542);

    // ── left arm inner going down to hand ─────────────────────────────────────
    p.cubicTo(
      w * 0.234, h * 0.578,
      w * 0.230, h * 0.614,
      w * 0.227, h * 0.638,
    );
    p.cubicTo(
      w * 0.224, h * 0.660,
      w * 0.210, h * 0.672,
      w * 0.190, h * 0.674,
    ); // inner hand
    p.cubicTo(
      w * 0.170, h * 0.676,
      w * 0.156, h * 0.666,
      w * 0.152, h * 0.648,
    ); // hand bottom
    p.cubicTo(
      w * 0.148, h * 0.624,
      w * 0.154, h * 0.590,
      w * 0.156, h * 0.562,
    ); // outer hand

    // ── left arm outer going up ───────────────────────────────────────────────
    p.lineTo(w * 0.152, h * 0.480);
    p.cubicTo(
      w * 0.148, h * 0.370,
      w * 0.160, h * 0.250,
      w * 0.180, h * 0.214,
    );

    // ── left shoulder sweeping in ─────────────────────────────────────────────
    p.cubicTo(
      w * 0.200, h * 0.178,
      w * 0.440, h * 0.172,
      w * 0.453, h * 0.172,
    );

    // ── left neck ────────────────────────────────────────────────────────────
    p.cubicTo(
      w * 0.453, h * 0.158,
      w * 0.446, h * 0.146,
      w * 0.435, h * 0.138,
    );

    // ── left head arc back to top ─────────────────────────────────────────────
    p.cubicTo(
      w * 0.342, h * 0.124,
      w * 0.364, h * 0.007,
      w * 0.500, h * 0.008,
    );

    p.close();
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPath = _buildBodyPath(size);

    // 1. Body background (unfilled area)
    final bgPaint = Paint()
      ..color = isLight
          ? AppColors.primary200Light
          : const Color(0xFF0D2952)
      ..style = PaintingStyle.fill;
    canvas.drawPath(bodyPath, bgPaint);

    // 2. Water fill clipped to body silhouette
    if (progress > 0.001) {
      canvas.save();
      canvas.clipPath(bodyPath);

      final clampedProgress = progress.clamp(0.0, 1.0);
      final waterY = size.height * (1.0 - clampedProgress);
      final waveAmplitude = size.height * 0.018;
      final waveFreq = 2 * pi / size.width;

      // Build wave path (water surface with sine wave)
      final wavePath = Path();
      wavePath.moveTo(0, size.height);
      wavePath.lineTo(0, waterY);
      for (double x = 0; x <= size.width; x++) {
        final y = waterY +
            sin(x * waveFreq * 2 + wavePhase) * waveAmplitude +
            cos(x * waveFreq + wavePhase * 0.5) * (waveAmplitude * 0.5);
        wavePath.lineTo(x, y);
      }
      wavePath.lineTo(size.width, size.height);
      wavePath.close();

      // Water gradient fill
      final waterPaint = Paint()
        ..shader = LinearGradient(
          colors: isLight
              ? [AppColors.primary300Light, AppColors.primary500Light]
              : [const Color(0xFF014389), const Color(0xFF0094FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(
          Rect.fromLTWH(0, waterY, size.width, size.height - waterY),
        )
        ..style = PaintingStyle.fill;
      canvas.drawPath(wavePath, waterPaint);

      // Subtle highlight shimmer on water surface
      final shimmerPath = Path();
      shimmerPath.moveTo(0, waterY);
      for (double x = 0; x <= size.width; x++) {
        final y = waterY +
            sin(x * waveFreq * 2 + wavePhase + pi) * (waveAmplitude * 0.6) +
            cos(x * waveFreq + wavePhase * 0.5 + pi) * (waveAmplitude * 0.3);
        shimmerPath.lineTo(x, y);
      }
      shimmerPath.lineTo(size.width, waterY + waveAmplitude * 2.5);
      shimmerPath.lineTo(0, waterY + waveAmplitude * 2.5);
      shimmerPath.close();

      final shimmerPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..style = PaintingStyle.fill;
      canvas.drawPath(shimmerPath, shimmerPaint);

      canvas.restore();
    }

    // 3. Body outline on top of everything
    final outlinePaint = Paint()
      ..color = isLight
          ? AppColors.primary500Light.withValues(alpha: 0.45)
          : const Color(0xFF00E0FF).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(bodyPath, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant _HumanBodyPainter old) =>
      old.progress != progress ||
      old.wavePhase != wavePhase ||
      old.isLight != isLight;
}
