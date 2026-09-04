import "dart:math";
import "dart:ui" as ui;

import "package:dsp_base/app_material.dart";
import "package:flutter/services.dart" show rootBundle;

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
    this.width = 200,
    this.textScale = 1.0,
    this.isFemale = false,
  });

  final double progress; // 0.0 to 1.0
  final int currentMl;
  final int goalMl;
  final String volumeUnit;
  final double width;
  final double textScale;

  /// Female / male body artwork (raster PNG, 1024×1536).
  final bool isFemale;

  /// Body-art aspect (1536/1024). Kept for layouts that size a body prop,
  /// e.g. the organ diagram.
  static const double svgAspect = 1536 / 1024; // 1.5

  @override
  State<WaterHumanProgress> createState() => _WaterHumanProgressState();
}

class _WaterHumanProgressState extends State<WaterHumanProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ripple;
  ui.Image? _maskImage;

  // Silhouette + its viewBox, switched by gender. Both the outline and the
  // clipped water rise must use the same asset/geometry.
  String get _asset => widget.isFemale
      ? "assets/images/png/img_women.png"
      : "assets/images/png/img_men.png";
  // Logical wave-space coords; only the ratio matters (painter scales to size).
  double get vbW => 198.67; // 298 / 1.5
  double get vbH => 298;
  double get _svgAspect => vbH / vbW;

  @override
  void initState() {
    super.initState();
    _ripple = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    // Wave motion temporarily disabled for smoothness — water level still shows
    // statically. Re-enable with `..repeat()` above.
    _loadMask();
  }

  @override
  void didUpdateWidget(WaterHumanProgress old) {
    super.didUpdateWidget(old);
    // Gender changed → rebuild the water-clip mask from the new silhouette.
    if (old.isFemale != widget.isFemale) {
      _maskImage?.dispose();
      _maskImage = null;
      _loadMask();
    }
  }

  // Rasterises human.svg at display size for use as alpha mask in _HumanWaterPainter.
  // Water animates immediately; clip is applied once mask is ready.
  // Decode the body PNG (transparent background) for use as the alpha mask that
  // clips the rising water to the body shape.
  Future<void> _loadMask() async {
    try {
      final data = await rootBundle.load(_asset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      if (mounted) setState(() => _maskImage = frame.image);
    } catch (_) {}
  }

  @override
  void dispose() {
    _ripple.dispose();
    _maskImage?.dispose();
    super.dispose();
  }

  // Keep the silhouette HEIGHT constant across genders (both viewBoxes are 298
  // tall); derive width from the gender aspect so the female body stays slim
  // instead of being stretched to the male width.
  double get _bodyHeight => widget.width * 0.45 * WaterHumanProgress.svgAspect;
  double get _bodyWidth => _bodyHeight / _svgAspect;

  @override
  Widget build(BuildContext context) {
    final bodyW = _bodyWidth;
    final bodyH = bodyW * _svgAspect;

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
              // Layer 1: Human body artwork (unfilled region).
              Image.asset(_asset, fit: BoxFit.fill),

              // Layer 2: Animated water rising from the feet, clipped to body shape.
              AnimatedBuilder(
                animation: _ripple,
                builder: (_, child) => CustomPaint(
                  painter: _HumanWaterPainter(
                    fillFraction: animProgress,
                    phase: _ripple.value,
                    maskImage: _maskImage,
                    vbW: vbW,
                    vbH: vbH,
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
    required this.vbW,
    required this.vbH,
    this.maskImage,
  });

  final double fillFraction;
  final double phase;
  final ui.Image? maskImage;

  /// Silhouette viewBox, gender-dependent (male 130×298, female 83×298).
  final double vbW;
  final double vbH;

  static const int _segments = 32;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = fillFraction.clamp(0.0, 1.0);
    if (fill <= 0) return;

    // Outer compositing group: water drawn here, then masked to body shape.
    canvas.saveLayer(Offset.zero & size, Paint());

    // Guard strip: exclude the very top edge of the artwork. The exported PNG
    // has a faint non-transparent top row; without this, a full-width line
    // appears across the top when the body fills completely.
    final topGuard = size.height * 0.02;
    canvas.clipRect(
      Rect.fromLTWH(0, topGuard, size.width, size.height - topGuard),
    );

    // Draw in viewBox space so wave parameters are SVG-coordinate-relative.
    canvas.save();
    canvas.scale(size.width / vbW, size.height / vbH);

    final bob = sin(phase * 2 * pi) * 3.0 * fill;
    final amplitude = (4.0 + 4.5 * fill) * (fill < 0.06 ? fill / 0.06 : 1.0);
    // When (near) full, push the whole surface above the body top so its wavy
    // crest + glint line get clipped away by the mask — otherwise a stray
    // horizontal line shows across the chest.
    final atTop = fill >= 0.985;
    final surfaceY = atTop ? -amplitude - 6 : vbH * (1 - fill) + bob;

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
        ).createShader(Rect.fromLTWH(0, surfaceY, vbW, vbH - surfaceY))
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
        ).createShader(Rect.fromLTWH(0, surfaceY, vbW, vbH - surfaceY))
        ..style = PaintingStyle.fill,
    );

    // Glint along the front wave crest — hidden when full (no surface to show).
    if (!atTop) {
      canvas.drawPath(
        _waveLine(surfaceY, amplitude, 1, -phase * 2 * pi + pi / 3),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    canvas.restore();

    // Clip water to the human body: dstIn keeps only pixels where the
    // rasterised SVG (maskImage) is opaque. Applied directly inside the outer
    // layer — no second saveLayer — since saveLayer is the costly per-frame op.
    final mask = maskImage;
    if (mask != null) {
      canvas.drawImageRect(
        mask,
        Rect.fromLTWH(0, 0, mask.width.toDouble(), mask.height.toDouble()),
        Offset.zero & size,
        Paint()..blendMode = BlendMode.dstIn,
      );
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
      ..lineTo(vbW, vbH)
      ..lineTo(0, vbH)
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
      final x = vbW * i / _segments;
      final angle = (x / vbW) * waveCount * 2 * pi + shift;
      path.lineTo(x, baseY + sin(angle) * amplitude);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _HumanWaterPainter old) =>
      old.fillFraction != fillFraction ||
      old.phase != phase ||
      old.maskImage != maskImage ||
      old.vbW != vbW;
}
