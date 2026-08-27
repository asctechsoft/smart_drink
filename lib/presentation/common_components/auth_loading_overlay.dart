import 'package:dsp_base/app_material.dart';
import 'package:waternudge/controller/auth_controller.dart';
import 'package:get/get.dart';

/// Wrap around Scaffold/screen root. Shows animated fullscreen overlay
/// whenever AuthController.isLoading is true.
class AuthLoadingOverlay extends StatefulWidget {
  final Widget child;
  const AuthLoadingOverlay({super.key, required this.child});

  @override
  State<AuthLoadingOverlay> createState() => _AuthLoadingOverlayState();
}

class _AuthLoadingOverlayState extends State<AuthLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Obx(() {
          if (!AuthController.to.isLoading.value) {
            return const SizedBox.shrink();
          }
          return AnimatedOpacity(
            opacity: AuthController.to.isLoading.value ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 220),
            child: Material(
              color: Colors.transparent,
              child: Container(
                color: Colors.black.withValues(alpha: 0.55),
                child: Center(
                  child: _SpinnerCard(spin: _spin),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _SpinnerCard extends StatelessWidget {
  final AnimationController spin;
  const _SpinnerCard({required this.spin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E35).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: spin,
          builder: (_, __) => Transform.rotate(
            angle: spin.value * 6.2832, // 2π
            child: SizedBox(
              width: 44,
              height: 44,
              child: CustomPaint(painter: _ArcPainter()),
            ),
          ),
        ),
      ),
    );
  }
}

/// Teal gradient arc spinner — matches app color (#57DCC0).
class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 4.0;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [Color(0x0057DCC0), Color(0xFF57DCC0)],
        startAngle: 0,
        endAngle: 6.2832,
      ).createShader(rect);

    canvas.drawArc(rect, -1.5708, 5.5, false, paint); // ~315° arc
  }

  @override
  bool shouldRepaint(_ArcPainter old) => false;
}
