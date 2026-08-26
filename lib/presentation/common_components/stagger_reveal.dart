import 'package:flutter/material.dart';

/// Fades + slides a widget up into place once, on mount. [index] staggers the
/// start so a column of these reveals top-to-bottom.
class StaggerReveal extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration duration;
  final double offsetY;

  const StaggerReveal({
    super.key,
    required this.child,
    this.index = 0,
    this.baseDelay = const Duration(milliseconds: 85),
    this.duration = const Duration(milliseconds: 460),
    this.offsetY = 26,
  });

  @override
  State<StaggerReveal> createState() => _StaggerRevealState();
}

class _StaggerRevealState extends State<StaggerReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    _anim = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    Future.delayed(widget.baseDelay * widget.index, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) {
        final t = _anim.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * widget.offsetY),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// A [Column] whose direct children reveal top-to-bottom with a stagger.
/// Layout-only widgets ([Spacer], [Expanded], [Flexible], [SizedBox]) pass
/// through unwrapped so they don't break the Flex or waste stagger slots.
class StaggerColumn extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final int startIndex;
  final EdgeInsetsGeometry? padding;

  const StaggerColumn({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.startIndex = 0,
    this.padding,
  });

  bool _isPassthrough(Widget w) =>
      w is Spacer || w is Expanded || w is Flexible || w is SizedBox;

  @override
  Widget build(BuildContext context) {
    var i = startIndex;
    final column = Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: [
        for (final c in children)
          if (_isPassthrough(c)) c else StaggerReveal(index: i++, child: c),
      ],
    );
    if (padding == null) return column;
    return Padding(padding: padding!, child: column);
  }
}
