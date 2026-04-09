import 'package:smartdrinkai/values/app_colors.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaterWaveBackground extends StatefulWidget {
  final Widget child;

  const WaterWaveBackground({super.key, required this.child});

  @override
  State<WaterWaveBackground> createState() => _WaterWaveBackgroundState();
}

class _WaterWaveBackgroundState extends State<WaterWaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Tốc độ di chuyển của sóng
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Stack(
      children: [
        // Nền tối ở phía sau
        Container(
          decoration: BoxDecoration(
            gradient: isLight
                ? AppColors.gradientBgLight
                : AppColors.gradientBgDark,
          ),
        ),
        // Lớp vẽ sóng nước động
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _WavePainter(_controller.value, context),
              );
            },
          ),
        ),
        // Nội dung UI đè lên trên lớp sóng
        widget.child,
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final BuildContext context;
  _WavePainter(this.progress, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final ob = OnboardingTheme.of(context);
    // Chiều cao chân sóng: nằm ở 300px tính từ phần bottom của màn.
    final bottomHeight = 300.0;

    // Khung vẽ sóng sẽ nằm ở dưới

    // Sóng 1 (Phía xa mờ nhất)
    _drawWave(
      canvas,
      size,
      paint: Paint()
        ..color = ob.waterWave1
        ..style = PaintingStyle.fill,
      waveCount: 1.5,
      amplitude: 10.0,
      baseHeightY: size.height - bottomHeight + 30,
      phaseShift: progress * 2 * math.pi * 2, // Sóng di chuyển sang trái
    );

    // // Sóng 2 (Ở giữa)
    _drawWave(
      canvas,
      size,
      paint: Paint()
        ..color = ob.waterWave2
        ..style = PaintingStyle.fill,
      waveCount: 1,
      amplitude: 12.0,
      baseHeightY: size.height - bottomHeight + 40,
      phaseShift:
          -progress * 2 * math.pi + math.pi / 2, // Sóng di chuyển sang phải
    );
    // // Sóng 3 (Phía trước nhất - Màu đặc)
    _drawWave(
      canvas,
      size,
      paint: Paint()
        ..color = ob.waterWave3
        ..style = PaintingStyle.fill,
      waveCount: 1,
      amplitude: 14.0,
      baseHeightY: size.height - bottomHeight + 50,
      phaseShift:
          progress * 2 * math.pi * 2, // Sóng di chuyển sang trái nhanh gấp đôi
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size, {
    required Paint paint,
    required double waveCount,
    required double amplitude,
    required double baseHeightY,
    required double phaseShift,
  }) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, baseHeightY);

    // Dựng path mềm bám theo hình sin
    final segments = 200; // Độ mượt của đường viền sóng
    for (int i = 0; i <= segments; i++) {
      final x = (i / segments) * size.width;
      // Quy đổi hoành độ x ra góc radians
      final angle = (x / size.width) * waveCount * 2 * math.pi + phaseShift;
      final y = baseHeightY + math.sin(angle) * amplitude;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

