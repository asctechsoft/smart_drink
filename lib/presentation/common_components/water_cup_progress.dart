import 'dart:math';
import 'package:dsp_base/app_material.dart';

class WaterCupProgress extends StatefulWidget {
  final double progress;
  final int currentMl;
  final int goalMl;
  final String volumeUnit;
  final double width;
  final double height;

  const WaterCupProgress({
    super.key,
    required this.progress,
    required this.currentMl,
    required this.goalMl,
    this.volumeUnit = 'ml',
    this.width = 300,
    this.height = 300,
  });

  @override
  State<WaterCupProgress> createState() => _WaterCupProgressState();
}

class _WaterCupProgressState extends State<WaterCupProgress>
    with TickerProviderStateMixin {
  late final AnimationController _waveController;
  late AnimationController _fillController;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fillController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fillAnimation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _fillController, curve: Curves.easeOutCubic),
    );
    _fillController.forward();
  }

  @override
  void didUpdateWidget(WaterCupProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      final from = _fillAnimation.value;
      _fillController.reset();
      _fillAnimation = Tween<double>(begin: from, end: widget.progress).animate(
        CurvedAnimation(parent: _fillController, curve: Curves.easeOutCubic),
      );
      _fillController.forward();
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
    final size = widget.width;

    return AnimatedBuilder(
      animation: Listenable.merge([_waveController, _fillAnimation]),
      builder: (context, _) {
        final animFill = _fillAnimation.value;

        return SizedBox(
          width: size,
          height: size + 8,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Background circle
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF021447),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0094FF).withValues(alpha: 0.25),
                      blurRadius: 32,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),

              // Wave + scale marks inside the circle
              ClipOval(
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: _WavePainter(
                          wavePhase: _waveController.value,
                          fillLevel: animFill.clamp(0.0, 1.0),
                        ),
                        size: Size(size, size),
                      ),
                      CustomPaint(
                        painter: _ScalePainter(
                          goalMl: widget.goalMl,
                          volumeUnit: widget.volumeUnit,
                        ),
                        size: Size(size, size),
                      ),
                    ],
                  ),
                ),
              ),

              // Ring border glow
              SizedBox(
                width: size,
                height: size,
                child: CustomPaint(painter: _RingBorderPainter()),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Scale marks — drawn inside the left portion of the circle
// ---------------------------------------------------------------------------

class _ScalePainter extends CustomPainter {
  final int goalMl;
  final String volumeUnit;

  const _ScalePainter({required this.goalMl, required this.volumeUnit});

  @override
  void paint(Canvas canvas, Size size) {
    if (goalMl <= 0) return;

    final r = size.width / 2;
    final cx = r;
    final cy = r;
    final marks = _getMarks();
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final ml in marks) {
      final ratio = ml / goalMl;
      final y = size.height * (1 - ratio);

      final dy = y - cy;
      if (dy.abs() > r - 8) continue; // too close to top/bottom edge

      final dx = sqrt(r * r - dy * dy);
      final leftEdge = cx - dx; // x of left circle wall at this y

      // Tick line inside the circle
      canvas.drawLine(
        Offset(leftEdge + 4, y),
        Offset(leftEdge + 18, y),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..strokeWidth = 1.0,
      );

      // Label text
      final label = _formatMark(ml);
      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 10,
          color: Colors.white.withValues(alpha: 0.7),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(leftEdge + 22, y - textPainter.height / 2),
      );
    }
  }

  List<int> _getMarks() {
    const steps = [100, 200, 250, 300, 400, 500, 750, 1000];
    for (final step in steps) {
      final count = goalMl ~/ step;
      if (count >= 3 && count <= 6) {
        return List.generate(count, (i) => (i + 1) * step)
            .where((ml) => ml < goalMl)
            .toList();
      }
    }
    return [goalMl ~/ 4, goalMl ~/ 2, goalMl * 3 ~/ 4];
  }

  String _formatMark(int ml) {
    if (volumeUnit == 'oz') {
      final oz = ml * 0.033814;
      return '${oz.toStringAsFixed(oz < 10 ? 1 : 0)}oz';
    }
    if (ml >= 1000) {
      final l = ml / 1000.0;
      return '${l == l.floorToDouble() ? l.toInt() : l.toStringAsFixed(1)}L';
    }
    return '${ml}ml';
  }

  @override
  bool shouldRepaint(_ScalePainter old) =>
      old.goalMl != goalMl || old.volumeUnit != volumeUnit;
}

// ---------------------------------------------------------------------------
// Wave painter
// ---------------------------------------------------------------------------

class _WavePainter extends CustomPainter {
  final double wavePhase;
  final double fillLevel;

  const _WavePainter({required this.wavePhase, required this.fillLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fillY = h * (1 - fillLevel);
    final amplitude = 6.0 + (1 - fillLevel) * 8.0;
    final phase = wavePhase * 2 * pi;

    // Front wave
    final path1 = Path();
    path1.moveTo(0, fillY + amplitude * sin(phase));
    for (double x = 0; x <= w; x += 1) {
      path1.lineTo(x, fillY + amplitude * sin((x / w * 2 * pi) + phase));
    }
    path1.lineTo(w, h);
    path1.lineTo(0, h);
    path1.close();

    final rect = Rect.fromLTWH(0, fillY - amplitude, w, h - fillY + amplitude);
    canvas.drawPath(
      path1,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF00CFFF).withValues(alpha: 0.85),
            const Color(0xFF0060FF),
          ],
        ).createShader(rect),
    );

    // Back wave
    final phase2 = phase + pi * 0.65;
    final path2 = Path();
    path2.moveTo(0, fillY + amplitude * 0.6 * sin(phase2));
    for (double x = 0; x <= w; x += 1) {
      path2.lineTo(
        x,
        fillY + amplitude * 0.6 * sin((x / w * 2 * pi) + phase2),
      );
    }
    path2.lineTo(w, h);
    path2.lineTo(0, h);
    path2.close();

    canvas.drawPath(
      path2,
      Paint()..color = const Color(0xFF0050DD).withValues(alpha: 0.45),
    );

  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.wavePhase != wavePhase || old.fillLevel != fillLevel;
}

// ---------------------------------------------------------------------------
// Ring border
// ---------------------------------------------------------------------------

class _RingBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 1,
      Paint()
        ..color = const Color(0xFF00E0FF).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_RingBorderPainter _) => false;
}
