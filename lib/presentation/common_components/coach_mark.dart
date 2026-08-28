import 'package:flutter/material.dart';

/// One step in a coach-mark walkthrough: spotlight [key]'s widget and show
/// [text] in a callout bubble.
class CoachStep {
  final GlobalKey key;
  final String text;
  final String? title;

  /// Corner radius of the spotlight cutout. Use a large value for pill buttons.
  final double radius;

  /// Optional: a fresh copy of the target widget. When provided, the coach mark
  /// paints it scaled-up (pulsing) in place so the button itself appears to
  /// grow — no white border box around it.
  final Widget Function()? spotlightBuilder;

  const CoachStep({
    required this.key,
    required this.text,
    this.title,
    this.radius = 18,
    this.spotlightBuilder,
  });
}

/// Show a sequential coach-mark overlay that spotlights each step's target
/// widget. Steps whose target isn't laid out are skipped. Calls [onFinish]
/// once dismissed (use it to persist "seen").
void showCoachMarks(
  BuildContext context,
  List<CoachStep> steps, {
  VoidCallback? onFinish,
  String nextLabel = 'Tiếp',
  String doneLabel = 'Đã hiểu',
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _CoachMarkOverlay(
      steps: steps,
      nextLabel: nextLabel,
      doneLabel: doneLabel,
      onFinish: () {
        entry.remove();
        onFinish?.call();
      },
    ),
  );
  overlay.insert(entry);
}

class _CoachMarkOverlay extends StatefulWidget {
  final List<CoachStep> steps;
  final VoidCallback onFinish;
  final String nextLabel;
  final String doneLabel;

  const _CoachMarkOverlay({
    required this.steps,
    required this.onFinish,
    required this.nextLabel,
    required this.doneLabel,
  });

  @override
  State<_CoachMarkOverlay> createState() => _CoachMarkOverlayState();
}

class _CoachMarkOverlayState extends State<_CoachMarkOverlay>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  late final AnimationController _pulse;

  static const double _gap = 22; // gap between target and bubble (arrow lives here)
  static const double _arrowW = 26;
  static const double _arrowH = 14;
  static const double _growScale = 0.10; // how much the target grows at peak
  static const Color _accent = Color(0xFF3E79FA);

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Rect? _rectFor(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final offset = box.localToGlobal(Offset.zero);
    return offset & box.size;
  }

  /// Advance to the next step that has a resolvable target, or finish.
  void _next() {
    var i = _index + 1;
    while (i < widget.steps.length && _rectFor(widget.steps[i].key) == null) {
      i++;
    }
    if (i >= widget.steps.length) {
      widget.onFinish();
    } else {
      setState(() => _index = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final step = widget.steps[_index];
    final target = _rectFor(step.key);

    if (target == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _next());
      return const SizedBox.shrink();
    }

    final isLast = _index == widget.steps.length - 1;
    final hasClone = step.spotlightBuilder != null;
    // Arrow + bubble anchor on the STATIC target so they never jitter.
    final below = target.center.dy < size.height / 2;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Scrim built once per step (no per-frame rebuild).
          //  - clone step: full scrim, the scaled copy is painted on top.
          //  - plain step: a tight borderless hole reveals the real widget.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _next,
              child: CustomPaint(
                painter: _HolePainter(
                  rect: hasClone ? null : target,
                  radius: step.radius,
                ),
              ),
            ),
          ),
          // Only the Transform.scale rebuilds each frame; the cloned button is
          // built once and cached as a layer via RepaintBoundary.
          if (hasClone)
            Positioned(
              left: target.left,
              top: target.top,
              width: target.width,
              height: target.height,
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _pulse,
                    child: step.spotlightBuilder!(),
                    builder: (context, child) => Transform.scale(
                      scale: 1.0 +
                          _growScale * Curves.easeInOut.transform(_pulse.value),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          _buildArrow(size, target, below),
          _buildBubble(size, target, below, step, isLast),
        ],
      ),
    );
  }

  Widget _buildArrow(Size size, Rect spotlight, bool below) {
    const margin = 20.0;
    final x = (spotlight.center.dx - _arrowW / 2)
        .clamp(margin + 8, size.width - margin - 8 - _arrowW);
    // `below` = bubble is under the target → arrow sits above the bubble,
    // pointing UP at the target. Otherwise arrow points DOWN.
    final double top = below
        ? spotlight.bottom + (_gap - _arrowH) / 2
        : spotlight.top - _gap + (_gap - _arrowH) / 2;
    return Positioned(
      left: x,
      top: top,
      child: IgnorePointer(
        child: CustomPaint(
          size: const Size(_arrowW, _arrowH),
          painter: _ArrowPainter(pointUp: below, color: _accent),
        ),
      ),
    );
  }

  Widget _buildBubble(
    Size size,
    Rect spotlight,
    bool below,
    CoachStep step,
    bool isLast,
  ) {
    const margin = 20.0;
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7BF6), Color(0xFF4F7BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (step.title != null) ...[
            Text(
              step.title!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            step.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _next,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  isLast ? widget.doneLabel : widget.nextLabel,
                  style: const TextStyle(
                    color: Color(0xFF1B3A8C),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final top = below ? spotlight.bottom + _gap : null;
    final bottom = below ? null : size.height - spotlight.top + _gap;

    return Positioned(
      left: margin,
      right: margin,
      top: top,
      bottom: bottom,
      child: Align(
        alignment: below ? Alignment.topCenter : Alignment.bottomCenter,
        child: bubble,
      ),
    );
  }
}

class _HolePainter extends CustomPainter {
  final Rect? rect;
  final double radius;

  _HolePainter({required this.rect, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final scrim = Paint()..color = Colors.black.withValues(alpha: 0.72);
    final r = rect;
    if (r == null) {
      canvas.drawRect(Offset.zero & size, scrim);
      return;
    }
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(r, Radius.circular(radius)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, scrim);
  }

  @override
  bool shouldRepaint(_HolePainter old) =>
      old.rect != rect || old.radius != radius;
}

class _ArrowPainter extends CustomPainter {
  final bool pointUp;
  final Color color;

  _ArrowPainter({required this.pointUp, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    if (pointUp) {
      path
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) =>
      old.pointUp != pointUp || old.color != color;
}
