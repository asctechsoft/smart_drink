import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternudge/tour/tour_controller.dart';
import 'package:waternudge/tour/tour_steps.dart';

/// Mounted once, above the navigator (`main.dart`'s `CommApp.builder`), so it
/// can spotlight a widget on any route without each screen hosting an overlay
/// of its own. Renders nothing while `TourController.active` is false.
class TourOverlay extends StatelessWidget {
  const TourOverlay({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<TourController>()) return child;
    final controller = Get.find<TourController>();
    return Stack(
      children: [
        child,
        Obx(() {
          // Also depend on anchorGeneration so a late-registering anchor
          // (registered mid-build, after `active` flips) triggers a re-measure.
          controller.anchorGeneration.value;
          if (!controller.active.value) return const SizedBox.shrink();
          return _TourStepView(controller: controller);
        }),
      ],
    );
  }
}

class _TourStepView extends StatefulWidget {
  const _TourStepView({required this.controller});

  final TourController controller;

  @override
  State<_TourStepView> createState() => _TourStepViewState();
}

class _TourStepViewState extends State<_TourStepView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  Timer? _autoAdvanceTimer;
  int _lastIndex = -1;

  static const double _gap = 22; // gap between target and bubble (arrow lives here)
  static const double _arrowW = 26;
  static const double _arrowH = 14;
  static const double _growScale = 0.10; // how much the target grows at peak
  static const Color _accent = Color(0xFF3E79FA);

  /// The target never laid out within this long (e.g. hidden behind a sheet
  /// on a slow frame): move on instead of trapping the user behind the scrim.
  static const Duration _autoAdvanceAfter = Duration(seconds: 10);

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
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  void _armAutoAdvance(int forIndex) {
    if (_lastIndex == forIndex) return;
    _lastIndex = forIndex;
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(_autoAdvanceAfter, () {
      if (!mounted) return;
      widget.controller.next();
    });
  }

  void _clearAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final step = controller.step;
    final target = controller.anchorRect(step.anchorId);
    final size = MediaQuery.of(context).size;

    if (target == null) {
      _armAutoAdvance(controller.index.value);
      // Not laid out yet (registered this frame) — retry next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
      return const SizedBox.shrink();
    }
    _clearAutoAdvance();

    final isPulseVariant =
        controller.variant.value == TourController.variantPulse;
    final hasClone = isPulseVariant && step.spotlightBuilder != null;
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
              onTap: controller.next,
              child: CustomPaint(
                painter: _HolePainter(
                  rect: hasClone ? null : target,
                  radius: step.radius,
                ),
              ),
            ),
          ),
          // Only the Transform.scale rebuilds each frame; the cloned widget is
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
                      scale:
                          1.0 +
                          _growScale * Curves.easeInOut.transform(_pulse.value),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          _buildArrow(size, target, below),
          _buildBubble(size, target, below, step, controller),
          _buildSkip(controller),
        ],
      ),
    );
  }

  Widget _buildSkip(TourController controller) {
    return Positioned(
      top: 12,
      right: 12,
      child: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.skip,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildArrow(Size size, Rect spotlight, bool below) {
    const margin = 20.0;
    final x = (spotlight.center.dx - _arrowW / 2).clamp(
      margin + 8,
      size.width - margin - 8 - _arrowW,
    );
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
    TourStep step,
    TourController controller,
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
          if (step.titleKey != null) ...[
            Text(
              step.titleKey!.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            step.textKey.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${step.groupIndex}/${step.groupSize}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: step.isFirstInGroup
                ? MainAxisAlignment.end
                : MainAxisAlignment.spaceBetween,
            children: [
              if (!step.isFirstInGroup)
                GestureDetector(
                  onTap: controller.previous,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    'previous'.tr,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              GestureDetector(
                onTap: controller.next,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    step.isLastInGroup ? 'got_it'.tr : 'next'.tr,
                    style: const TextStyle(
                      color: Color(0xFF1B3A8C),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
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
