import "dart:math";
import "dart:ui" as ui;

import "package:dsp_base/app_material.dart";
import "package:flutter_svg/svg.dart";

/// Human-body-shaped water level indicator. Water rises from feet to headsửa
/// as [progress] goes from 0.0 to 1.0, clipped to the human silhouette.
/// The same ml / goal readout as WaterCupProgress appears below.
class WaterHumanProgress extends StatefulWidget {
  const WaterHumanProgress({
    required this.progress,
    required this.currentMl,
    required this.goalMl,
    super.key,
    this.volumeUnit = "ml",
    this.width = 280,
    this.textScale = 1.0,
  });

  final double progress; // 0.0 to 1.0
  final int currentMl;
  final int goalMl;
  final String volumeUnit;
  final double width;
  final double textScale;

  // human.svg viewBox: 130 x 298
  static const double _vbW = 130;
  static const double _vbH = 298;
  static const double svgAspect = _vbH / _vbW; // ~2.292

  @override
  State<WaterHumanProgress> createState() => _WaterHumanProgressState();
}

class _WaterHumanProgressState extends State<WaterHumanProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ripple;
  ui.Image? _maskImage;

  static const _asset = "assets/images/svg/human.svg";

  @override
  void initState() {
    super.initState();
    _ripple = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _loadMask();
  }

  // Rasterises human.svg at display size for use as alpha mask in _HumanWaterPainter.
  // Water animates immediately; clip is applied once mask is ready.
  Future<void> _loadMask() async {
    final bodyW = _bodyWidth;
    final bodyH = bodyW * WaterHumanProgress.svgAspect;
    final iW = bodyW.toInt().clamp(60, 600);
    final iH = bodyH.toInt().clamp(60, 1400);
    try {
      const loader = SvgAssetLoader(_asset);
      final pictureInfo = await vg.loadPicture(loader, null);
      final svgSize = pictureInfo.size;

      // Scale the SVG picture to the display dimensions.
      // Inset by 3px so the mask is slightly smaller than the body silhouette —
      // this keeps water from overlapping the outer glow/border of the body.
      const inset = 3.0;
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(
        recorder,
        Rect.fromLTWH(0, 0, iW.toDouble(), iH.toDouble()),
      );
      canvas.translate(inset, inset);
      canvas.scale(
        (iW - inset * 2) / svgSize.width,
        (iH - inset * 2) / svgSize.height,
      );
      canvas.drawPicture(pictureInfo.picture);
      pictureInfo.picture.dispose();
      final scaled = recorder.endRecording();
      final img = await scaled.toImage(iW, iH);
      scaled.dispose();

      if (mounted) setState(() => _maskImage = img);
    } catch (_) {}
  }

  @override
  void dispose() {
    _ripple.dispose();
    _maskImage?.dispose();
    super.dispose();
  }

  double get _bodyWidth => widget.width * 0.45;

  @override
  Widget build(BuildContext context) {
    final bodyW = _bodyWidth;
    final bodyH = bodyW * WaterHumanProgress.svgAspect;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: widget.progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, animProgress, _) {
        return SizedBox(
          width: bodyW,
          height: bodyH,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Layer 1: Human body in natural teal colour (unfilled region).
              SvgPicture.asset(_asset, fit: BoxFit.fill),

              // Layer 2: Animated water rising from the feet, clipped to body shape.
              AnimatedBuilder(
                animation: _ripple,
                builder: (_, child) => CustomPaint(
                  painter: _HumanWaterPainter(
                    fillFraction: animProgress,
                    phase: _ripple.value,
                    maskImage: _maskImage,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Draws animated water waves clipped to the human body silhouette.
///
/// Works in the SVG's own viewBox space (130 x 298) so wave geometry
/// stays proportional regardless of pixel dimensions. The body mask is
/// applied via BlendMode.dstIn: water pixels survive only where the
/// rasterised SVG is opaque (inside the body).
class _HumanWaterPainter extends CustomPainter {
  _HumanWaterPainter({
    required this.fillFraction,
    required this.phase,
    this.maskImage,
  });

  final double fillFraction;
  final double phase;
  final ui.Image? maskImage;

  static const int _segments = 48;
  static const double _vbW = WaterHumanProgress._vbW;
  static const double _vbH = WaterHumanProgress._vbH;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = fillFraction.clamp(0.0, 1.0);
    if (fill <= 0) return;

    // Outer compositing group: water drawn here, then masked to body shape.
    canvas.saveLayer(Offset.zero & size, Paint());

    // Draw in viewBox space so wave parameters are SVG-coordinate-relative.
    canvas.save();
    canvas.scale(size.width / _vbW, size.height / _vbH);

    final bob = sin(phase * 2 * pi) * 3.0 * fill;
    final surfaceY = _vbH * (1 - fill) + bob;
    final amplitude = (4.0 + 4.5 * fill) * (fill < 0.06 ? fill / 0.06 : 1.0);

    // Back wave: lighter, slightly higher, drifts right.
    canvas.drawPath(
      _wavePath(
        surfaceY - amplitude * 0.4,
        amplitude * 0.75,
        1.4,
        phase * 2 * pi,
      ),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF4DC0FC), Color(0xFF4D92FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, surfaceY, _vbW, _vbH - surfaceY))
        ..style = PaintingStyle.fill,
    );

    // Front wave: main water body, drifts left.
    canvas.drawPath(
      _wavePath(surfaceY, amplitude, 1, -phase * 2 * pi + pi / 3),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF00A1FB), Color(0xFF0063FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, surfaceY, _vbW, _vbH - surfaceY))
        ..style = PaintingStyle.fill,
    );

    // Glint along the front wave crest.
    canvas.drawPath(
      _waveLine(surfaceY, amplitude, 1, -phase * 2 * pi + pi / 3),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas.restore();

    // Clip water to the human body: dstIn keeps only pixels where the
    // rasterised SVG (maskImage) is opaque.
    final mask = maskImage;
    if (mask != null) {
      canvas.saveLayer(
        Offset.zero & size,
        Paint()..blendMode = BlendMode.dstIn,
      );
      canvas.drawImageRect(
        mask,
        Rect.fromLTWH(0, 0, mask.width.toDouble(), mask.height.toDouble()),
        Offset.zero & size,
        Paint(),
      );
      canvas.restore();
    }

    canvas.restore();
  }

  Path _wavePath(
    double baseY,
    double amplitude,
    double waveCount,
    double shift,
  ) {
    return _waveLine(baseY, amplitude, waveCount, shift)
      ..lineTo(_vbW, _vbH)
      ..lineTo(0, _vbH)
      ..close();
  }

  Path _waveLine(
    double baseY,
    double amplitude,
    double waveCount,
    double shift,
  ) {
    final path = Path()..moveTo(0, baseY + sin(shift) * amplitude);
    for (var i = 1; i <= _segments; i++) {
      final x = _vbW * i / _segments;
      final angle = (x / _vbW) * waveCount * 2 * pi + shift;
      path.lineTo(x, baseY + sin(angle) * amplitude);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _HumanWaterPainter old) =>
      old.fillFraction != fillFraction ||
      old.phase != phase ||
      old.maskImage != maskImage;
}
