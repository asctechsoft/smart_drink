import 'dart:math' as math;

import 'package:dsp_base/app_material.dart';
import 'package:get/get.dart';
import 'package:waternudge/values/app_colors.dart';

/// Plays the daily-goal celebration: translucent bubbles rise from the bottom
/// of the screen, and the larger ones burst into a firework spray on the way up.
///
/// Runs in an overlay above the current route and removes itself when the
/// animation ends, so callers fire and forget. Pointer events pass straight
/// through — the user can keep tapping while it plays.
void showBubbleCelebration([BuildContext? context]) {
  OverlayState? overlay;
  if (context != null && context.mounted) {
    overlay = Overlay.maybeOf(context);
  }
  overlay ??= Get.overlayContext != null
      ? Overlay.maybeOf(Get.overlayContext!)
      : null;
  overlay ??= Get.key.currentState?.overlay;
  if (overlay == null) return;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned.fill(
      child: IgnorePointer(
        child: _BubbleField(
          onDone: () {
            if (entry.mounted) entry.remove();
          },
        ),
      ),
    ),
  );
  overlay.insert(entry);
}

/// One streak thrown out by a bursting bubble.
class _Shard {
  const _Shard({
    required this.angle,
    required this.reach,
    required this.thickness,
  });

  /// Direction of travel, in radians.
  final double angle;

  /// Share of the burst's spread this streak covers, 0–1.
  final double reach;

  /// Stroke width at the head, in logical pixels.
  final double thickness;
}

/// One bubble's path, plus the burst it turns into. Everything is decided up
/// front so the painter stays a pure function of the animation value — no
/// per-frame particle state to keep in sync.
class _Bubble {
  const _Bubble({
    required this.x,
    required this.radius,
    required this.delay,
    required this.life,
    required this.sway,
    required this.swayCycles,
    required this.popAt,
    required this.shards,
    required this.spread,
    required this.color,
  });

  /// Horizontal start position, 0 (left edge) to 1 (right edge).
  final double x;

  /// Radius in logical pixels.
  final double radius;

  /// Share of the timeline to wait before rising, 0–1.
  final double delay;

  /// Share of the timeline this bubble owns, rise and burst together, 0–1.
  final double life;

  /// Horizontal sway amplitude in logical pixels.
  final double sway;

  /// How many times it sways left-right on the way up.
  final double swayCycles;

  /// Height it stops rising at, as a share of the field: 1 = top edge.
  final double popAt;

  /// Streaks thrown when it bursts. Empty for the small bubbles, which just
  /// fade out — 26 simultaneous fireworks would be noise, not celebration.
  final List<_Shard> shards;

  /// How far the streaks travel from the burst centre, in logical pixels.
  final double spread;

  /// Tint for both the bubble rim and its burst.
  final Color color;

  bool get bursts => shards.isNotEmpty;
}

class _BubbleField extends StatefulWidget {
  const _BubbleField({required this.onDone});

  final VoidCallback onDone;

  @override
  State<_BubbleField> createState() => _BubbleFieldState();
}

class _BubbleFieldState extends State<_BubbleField>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 2800);
  static const _count = 26;

  /// Bubbles at least this big burst into a firework; the rest just pop.
  static const _burstRadius = 11.0;

  /// Cool tints that read against the app's deep-violet background.
  static const _palette = [
    AppColors.primary500Dark, // 0xFF00E0FF
    AppColors.btnCyanEnd, // 0xFF83EFF3
    AppColors.accentTeal, // 0xFF57DCC0
    AppColors.basic500, // white
    AppColors.onboardingButtonStart, // 0xFF0094FF
  ];

  late final AnimationController _controller;
  late final List<_Bubble> _bubbles;

  @override
  void initState() {
    super.initState();

    // Generated once per celebration and unseeded, so hitting the goal on two
    // different days doesn't replay the identical arrangement.
    final random = math.Random();
    _bubbles = List.generate(_count, (i) {
      // Spread the starting columns evenly, then jitter, so bubbles cover the
      // width instead of clumping wherever the RNG happens to land.
      final column = (i + 0.5) / _count;
      final radius = 5 + random.nextDouble() * 13;
      final bursts = radius >= _burstRadius;
      final delay = random.nextDouble() * 0.42;

      return _Bubble(
        x: (column + (random.nextDouble() - 0.5) * 0.7 / _count).clamp(
          0.02,
          0.98,
        ),
        radius: radius,
        delay: delay,
        // Capped so a late bubble still finishes its burst before the
        // controller completes and the overlay is torn down — otherwise the
        // last fireworks get cut off mid-flight.
        life: math.min(0.5 + random.nextDouble() * 0.35, 1 - delay),
        sway: 6 + random.nextDouble() * 18,
        swayCycles: 0.6 + random.nextDouble() * 1.4,
        popAt: 0.6 + random.nextDouble() * 0.32,
        spread: 46 + random.nextDouble() * 44,
        color: _palette[random.nextInt(_palette.length)],
        shards: bursts ? _makeShards(random) : const [],
      );
    });

    _controller = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onDone();
      })
      ..forward();
  }

  static List<_Shard> _makeShards(math.Random random) {
    final count = 10 + random.nextInt(5);
    final step = 2 * math.pi / count;
    // Offset the whole ring so bursts don't all point the same way.
    final origin = random.nextDouble() * 2 * math.pi;
    return List.generate(count, (i) {
      return _Shard(
        // Even spacing plus jitter: a perfect ring looks mechanical, pure
        // random leaves visible gaps.
        angle: origin + i * step + (random.nextDouble() - 0.5) * step * 0.55,
        reach: 0.62 + random.nextDouble() * 0.38,
        thickness: 1.4 + random.nextDouble() * 1.4,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _BubblePainter(progress: _controller, bubbles: _bubbles),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  _BubblePainter({required this.progress, required this.bubbles})
    : super(repaint: progress);

  final Animation<double> progress;
  final List<_Bubble> bubbles;

  /// Share of a bubble's life spent rising; the rest is its burst.
  static const _riseShare = 0.72;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;

    for (final bubble in bubbles) {
      // Where this bubble is in its own life, independent of the others.
      final local = (t - bubble.delay) / bubble.life;
      if (local <= 0 || local >= 1) continue;

      final travel = math.min(local / _riseShare, 1.0);

      // Ease out so bubbles slow as they near the surface, then hang at the
      // burst point instead of drifting on through it.
      final rise = Curves.easeOutSine.transform(travel);

      // Start a full diameter below the bottom edge so none pops into being.
      final span = size.height + bubble.radius * 2;
      final center = Offset(
        size.width * bubble.x +
            math.sin(rise * bubble.swayCycles * 2 * math.pi) * bubble.sway,
        span - rise * span * bubble.popAt,
      );

      if (local < _riseShare) {
        _paintBubble(canvas, bubble, center, local / _riseShare);
      } else {
        final burst = (local - _riseShare) / (1 - _riseShare);
        if (bubble.bursts) {
          _paintBurst(canvas, bubble, center, burst);
        } else {
          _paintPop(canvas, bubble, center, burst);
        }
      }
    }
  }

  /// The rising bubble: soft body, bright rim, one specular dot.
  void _paintBubble(
    Canvas canvas,
    _Bubble bubble,
    Offset center,
    double phase,
  ) {
    // Fade in off the bottom edge, then hold.
    final opacity = phase < 0.16 ? phase / 0.16 : 1.0;
    final radius = bubble.radius;

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = bubble.color.withValues(alpha: 0.13 * opacity),
    );

    // The rim is what makes it read as a bubble rather than a dot.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = bubble.color.withValues(alpha: 0.55 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, radius * 0.12),
    );

    if (radius > 7) {
      canvas.drawCircle(
        center.translate(-radius * 0.32, -radius * 0.34),
        radius * 0.2,
        Paint()..color = AppColors.basic500.withValues(alpha: 0.5 * opacity),
      );
    }
  }

  /// A small bubble simply swelling and fading away.
  void _paintPop(Canvas canvas, _Bubble bubble, Offset center, double phase) {
    final opacity = 1 - phase;
    final radius = bubble.radius * (1 + phase * 0.5);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = bubble.color.withValues(alpha: 0.45 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.8, bubble.radius * 0.1 * opacity),
    );
  }

  /// The firework: a flash ring at the moment of the burst, then streaks flung
  /// outward that decelerate, sag under gravity and fade to nothing.
  void _paintBurst(Canvas canvas, _Bubble bubble, Offset center, double phase) {
    // Flash: a bright ring over the first fifth, covering the instant the
    // bubble's skin breaks so the streaks don't appear out of nowhere.
    if (phase < 0.2) {
      final flash = phase / 0.2;
      canvas.drawCircle(
        center,
        bubble.radius * (1 + flash * 2.2),
        Paint()
          ..color = bubble.color.withValues(alpha: 0.5 * (1 - flash))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 * (1 - flash),
      );
    }

    // Fast out of the gate, then coasting — how a real burst decays.
    final distance = Curves.easeOutCubic.transform(phase);
    // Gravity builds with the square of time, so the streaks arc over.
    final sag = phase * phase * bubble.spread * 0.42;
    // Hold full brightness briefly, then fade over the back half.
    final opacity = phase < 0.35 ? 1.0 : 1 - (phase - 0.35) / 0.65;

    for (final shard in bubble.shards) {
      final reach = bubble.spread * shard.reach * distance;
      final head = center.translate(
        math.cos(shard.angle) * reach,
        math.sin(shard.angle) * reach + sag,
      );
      // Tail trails back toward the burst centre and stretches with speed, so
      // each streak reads as motion rather than a floating dot.
      final tail = 0.34 * (1 - phase * 0.55);
      final back = Offset.lerp(center.translate(0, sag), head, 1 - tail)!;

      canvas.drawLine(
        back,
        head,
        Paint()
          ..color = bubble.color.withValues(alpha: 0.75 * opacity)
          ..strokeWidth = shard.thickness * (1 - phase * 0.5)
          ..strokeCap = StrokeCap.round,
      );

      // Bright head, the spark itself.
      canvas.drawCircle(
        head,
        shard.thickness * 0.85 * (1 - phase * 0.4),
        Paint()..color = AppColors.basic500.withValues(alpha: 0.85 * opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) =>
      oldDelegate.bubbles != bubbles;
}
