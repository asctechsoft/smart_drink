import 'dart:math' as math;

import 'package:dsp_base/app_material.dart';
import 'package:get/get.dart';
import 'package:waternudge/controller/onboarding_controller.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';
import 'package:waternudge/presentation/common_components/stagger_reveal.dart';
import 'package:waternudge/services/native/notification_channel.dart';
import 'package:waternudge/values/app_colors.dart';

/// Closing onboarding screen: runs a short analysis animation, then persists the
/// profile and moves on to the home screen.
class BuildingScheduleScreen extends StatefulWidget {
  const BuildingScheduleScreen({super.key});

  @override
  State<BuildingScheduleScreen> createState() => _BuildingScheduleScreenState();
}

class _BuildingScheduleScreenState extends State<BuildingScheduleScreen>
    with TickerProviderStateMixin {
  static const Duration _duration = Duration(milliseconds: 4200);

  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: _duration,
  );

  /// Drives the continuous rotation of the arc.
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  static const _steps = [
    'step_calculating_water_needs',
    'step_analyzing_habits',
    'step_building_schedule',
  ];

  bool _finished = false;

  @override
  void initState() {
    super.initState();
    // Ask for the notification permission here (while the analysis animation
    // runs) instead of at app launch.
    NotificationChannel.requestPermission();
    _progress.forward();
    _progress.addStatusListener((status) {
      if (status == AnimationStatus.completed) _finish();
    });
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;
    await Get.find<OnboardingController>().completeOnboarding();
  }

  @override
  void dispose() {
    _progress.dispose();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: StaggerColumn(
            padding: const EdgeInsets.all(24),
            children: [
              AppSpacerH40,
              _buildTitle(),
              AppSpacerH12,
              AppText(
                'building_schedule_subtitle'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.basic500.withValues(alpha: 0.72),
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: Listenable.merge([_progress, _spin]),
                builder: (context, _) => _buildRing(),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _progress,
                builder: (context, _) => AppColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 18,
                  children: List.generate(
                    _steps.length,
                    (i) => _buildStepRow(i),
                  ),
                ),
              ),
              AppSpacerH40,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.basic500,
          height: 1.35,
        ),
        children: [
          TextSpan(text: '${'building_schedule_title'.tr}\n'),
          TextSpan(
            text: 'building_schedule_highlight'.tr,
            style: const TextStyle(color: AppColors.accentTeal),
          ),
        ],
      ),
    );
  }

  Widget _buildRing() {
    final value = _progress.value;
    return SizedBox(
      width: 210,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(210),
            painter: _RingPainter(
              progress: value,
              rotation: _spin.value * 2 * math.pi,
            ),
          ),
          AppText(
            '${(value * 100).round()}%',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: AppColors.basic500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(int index) {
    // Each step owns an equal slice of the run and is ticked once it passes.
    final done = _progress.value >= (index + 1) / _steps.length;
    final active = !done && _progress.value >= index / _steps.length;
    final color = done
        ? AppColors.accentTeal
        : active
        ? AppColors.primary500Dark
        : AppColors.basic500.withValues(alpha: 0.4);

    return AppRow(
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: done
              ? Icon(Icons.check_circle, size: 22, color: color)
              : active
              ? CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(color),
                )
              : Icon(Icons.circle_outlined, size: 22, color: color),
        ),
        AppSpacerW12,
        Expanded(
          child: AppText(
            _steps[index].tr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: done || active ? FontWeight.w500 : FontWeight.w400,
              color: done || active
                  ? AppColors.basic500
                  : AppColors.basic500.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double rotation;

  _RingPainter({required this.progress, required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - stroke / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = AppColors.basic500.withValues(alpha: 0.14),
    );

    if (progress <= 0) return;

    // The arc keeps spinning while it fills, so the ring reads as working.
    canvas.drawArc(
      rect,
      rotation,
      progress * 2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          transform: GradientRotation(rotation),
          colors: const [
            AppColors.primary500Dark,
            AppColors.accentTeal,
            Color(0xFF3E8DFD),
            AppColors.primary500Dark,
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.rotation != rotation;
}
