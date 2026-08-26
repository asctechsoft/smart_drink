import 'package:dsp_base/app_material.dart';
import 'package:waternudge/presentation/common_components/water_human_progress.dart';

class _Organ {
  final String label;
  final String emoji;
  final double bodyFraction; // 0..1 vertical position on body SVG

  const _Organ(this.label, this.emoji, this.bodyFraction);
}

class BodyOrganDiagram extends StatelessWidget {
  const BodyOrganDiagram({
    super.key,
    required this.progress,
    required this.currentMl,
    required this.goalMl,
    this.volumeUnit = 'ml',
  });

  final double progress;
  final int currentMl;
  final int goalMl;
  final String volumeUnit;

  // humanPropWidth controls SVG size: svgW = humanPropWidth * 0.45
  static const double _humanPropWidth = 290.0;
  static const double _svgW = _humanPropWidth * 0.45; // ≈ 130.5
  static const double _svgH = _svgW * WaterHumanProgress.svgAspect; // ≈ 299
  static const double _cardW = 70.0;
  static const double _cardH = 68.0;

  static const _leftOrgans = [
    _Organ('NÃO', '🧠', 0.15),
    _Organ('DA & GAN', '💧🫀', 0.40),
    _Organ('CƠ BẮP', '💪', 0.67),
  ];

  static const _rightOrgans = [
    _Organ('TIM', '❤️', 0.28),
    _Organ('THẬN', '🫘', 0.50),
    _Organ('KHỚP', '🦴', 0.78),
  ];

  @override
  Widget build(BuildContext context) {
    const stackH = _svgH + 72.0;

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final totalW = constraints.maxWidth;
        final bodyLeft = (totalW - _svgW) / 2;
        final bodyRight = bodyLeft + _svgW;

        return SizedBox(
          width: totalW,
          height: stackH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Connecting lines
              Positioned.fill(
                child: CustomPaint(
                  painter: _LinePainter(
                    leftOrgans: _leftOrgans,
                    rightOrgans: _rightOrgans,
                    cardW: _cardW,
                    bodyLeft: bodyLeft,
                    bodyRight: bodyRight,
                    svgH: _svgH,
                  ),
                ),
              ),

              // Human body figure
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: WaterHumanProgress(
                    progress: progress,
                    currentMl: currentMl,
                    goalMl: goalMl,
                    volumeUnit: volumeUnit,
                    width: _humanPropWidth,
                  ),
                ),
              ),

              // % overlay centered on body
              Positioned(
                top: _svgH * 0.38,
                left: bodyLeft,
                width: _svgW,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${(progress * 100).clamp(0.0, 100.0).toInt()}%',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black38, blurRadius: 6)],
                      ),
                    ),
                    Text(
                      'NƯỚC',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
                      ),
                    ),
                  ],
                ),
              ),

              // Left organ cards
              ..._leftOrgans.map((o) {
                final top = (o.bodyFraction * _svgH - _cardH / 2).clamp(
                  0.0,
                  stackH - _cardH,
                );
                return Positioned(
                  left: 0,
                  top: top,
                  child: _OrganCard(organ: o),
                );
              }),

              // Right organ cards
              ..._rightOrgans.map((o) {
                final top = (o.bodyFraction * _svgH - _cardH / 2).clamp(
                  0.0,
                  stackH - _cardH,
                );
                return Positioned(
                  right: 0,
                  top: top,
                  child: _OrganCard(organ: o),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// ─── Organ card ───────────────────────────────────────────────────────────────

class _OrganCard extends StatelessWidget {
  const _OrganCard({required this.organ});
  final _Organ organ;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: BodyOrganDiagram._cardW,
      height: BodyOrganDiagram._cardH,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            organ.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A2340),
              letterSpacing: 0.2,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(organ.emoji, style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}

// ─── Line painter ─────────────────────────────────────────────────────────────

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.leftOrgans,
    required this.rightOrgans,
    required this.cardW,
    required this.bodyLeft,
    required this.bodyRight,
    required this.svgH,
  });

  final List<_Organ> leftOrgans;
  final List<_Organ> rightOrgans;
  final double cardW;
  final double bodyLeft;
  final double bodyRight;
  final double svgH;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    for (final o in leftOrgans) {
      final y = o.bodyFraction * svgH;
      canvas.drawLine(Offset(cardW, y), Offset(bodyLeft, y), linePaint);
      canvas.drawCircle(Offset(bodyLeft, y), 3, dotPaint);
    }

    for (final o in rightOrgans) {
      final y = o.bodyFraction * svgH;
      canvas.drawLine(
        Offset(bodyRight, y),
        Offset(size.width - cardW, y),
        linePaint,
      );
      canvas.drawCircle(Offset(bodyRight, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.bodyLeft != bodyLeft ||
      old.bodyRight != bodyRight ||
      old.svgH != svgH;
}
