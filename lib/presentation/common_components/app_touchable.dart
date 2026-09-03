import 'package:dsp_base/app_material.dart';

/// Wraps [child] with the app's standard tap affordance: a Material ripple
/// clipped to [borderRadius] plus a subtle press-down scale.
///
/// Use this instead of a bare [GestureDetector] on tappable cards and pills so
/// every touch surface reacts the same way as [PrimaryButton].
class AppTouchable extends StatefulWidget {
  const AppTouchable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.splashColor,
    this.highlightColor,
    this.pressedScale = 0.97,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Must match the child's own corner radius so the ripple stays inside it.
  final BorderRadius borderRadius;

  final Color? splashColor;
  final Color? highlightColor;

  /// Scale applied while the finger is down. Set to 1 to disable.
  final double pressedScale;

  @override
  State<AppTouchable> createState() => _AppTouchableState();
}

class _AppTouchableState extends State<AppTouchable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;

    return AnimatedScale(
      scale: enabled && _pressed ? widget.pressedScale : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Stack(
        // Hand the child the exact constraints we were given, so a stretched
        // parent (Expanded, IntrinsicHeight, CrossAxisAlignment.stretch) still
        // sizes the child instead of letting it shrink to its content.
        fit: StackFit.passthrough,
        children: [
          widget.child,
          // Ink layer sits above the child so the ripple shows over gradients
          // and images, which an underlying Material could not paint through.
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: widget.onTap,
                onLongPress: widget.onLongPress,
                onTapDown: (_) => _setPressed(true),
                onTapUp: (_) => _setPressed(false),
                onTapCancel: () => _setPressed(false),
                borderRadius: widget.borderRadius,
                splashColor:
                    widget.splashColor ?? Colors.white.withValues(alpha: 0.28),
                highlightColor:
                    widget.highlightColor ??
                    Colors.white.withValues(alpha: 0.12),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
