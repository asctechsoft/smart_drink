import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/history_controller.dart';
import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/controller/today_controller.dart';
import 'package:smartdrinkai/models/data_models/drink_record.dart';
import 'package:smartdrinkai/models/ui_models/drink_type.dart';
import 'package:smartdrinkai/presentation/common_components/bottom_safe_area.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/presentation/common_components/progress_ring.dart';
import 'package:smartdrinkai/services/native/widget_channel.dart';
import 'package:smartdrinkai/utils/unit_converter.dart';
import 'package:smartdrinkai/values/app_colors.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';

class WidgetPreviewScreen extends StatelessWidget {
  const WidgetPreviewScreen({super.key});

  void _onWidgetTap(BuildContext context, String widgetType) async {
    if (!Platform.isAndroid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Widget pinning is only available on Android'),
        ),
      );
      return;
    }

    final success = await WidgetChannel.requestPinWidget(widgetType);
    if (!context.mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Widget pinning requires Android 8.0 or higher'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation:
              0, // Quan trọng: tắt hiệu ứng đổi màu Material 3 khi scroll
          leading: IconButton(
            icon: AppIcon(
              'assets/images/svg/ic_back_left.svg',
              size: 24,
              tint: ob.textPrimary,
              autoMirror: true,
            ),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          title: AppText(
            'widget'.tr,
            style: TextStyle(
              color: ob.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            // --- Small ---
            _sectionTitle('small'.tr, context),
            AppSpacerH12,
            Row(
              children: [
                Expanded(
                  child: _WidgetTapWrapper(
                    onTap: () => _onWidgetTap(context, 'small_a'),
                    child: const _SmallWidgetA(),
                  ),
                ),
                AppSpacerW8,
                Expanded(
                  child: _WidgetTapWrapper(
                    onTap: () => _onWidgetTap(context, 'small_b'),
                    child: const _SmallWidgetB(),
                  ),
                ),
              ],
            ),
            AppSpacerH20,
            // --- Medium ---
            _sectionTitle('medium'.tr, context),
            AppSpacerH12,
            _WidgetTapWrapper(
              onTap: () => _onWidgetTap(context, 'medium_a'),
              child: const _MediumWidgetA(),
            ),
            AppSpacerH12,
            _WidgetTapWrapper(
              onTap: () => _onWidgetTap(context, 'medium_b'),
              child: const _MediumWidgetB(),
            ),
            AppSpacerH20,
            // --- Large ---
            _sectionTitle('large'.tr, context),
            AppSpacerH12,
            _WidgetTapWrapper(
              onTap: () => _onWidgetTap(context, 'large'),
              child: const _LargeWidget(),
            ),

            BottomSafeArea(),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: ob.textPrimary,
      ),
    );
  }
}

/// Wraps a widget preview card with tap-to-pin behavior
class _WidgetTapWrapper extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _WidgetTapWrapper({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: child);
  }
}

// =============================================================================
// SMALL WIDGET A — Circular progress with water drop
// =============================================================================
class _SmallWidgetA extends StatelessWidget {
  const _SmallWidgetA();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 162,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.gradientWidgetA,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Mini progress ring with water drop and text
          Positioned(
            top: 10,
            left: 2,
            right: 2,
            bottom: 44,
            child: Transform.scale(
              scale: 1,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Obx(() {
                  double progress = 0.75;
                  int currentMl = 1500;
                  int goalMl = 2000;
                  if (Get.isRegistered<TodayController>()) {
                    final controller = Get.find<TodayController>();
                    progress = controller.progress;
                    currentMl = controller.currentIntakeMl.value;
                    goalMl = controller.adjustedGoal;
                  }
                  final volumeUnit = Get.isRegistered<SettingsController>()
                      ? Get.find<SettingsController>().volumeUnit.value
                      : 'ml';
                  return ProgressRing(
                    progress: progress,
                    currentMl: currentMl,
                    goalMl: goalMl,
                    volumeUnit: volumeUnit,
                    textScale: 1,
                    isWidget: true,
                  );
                }),
              ),
            ),
          ),
          // Bottom row: Add Drink + cup icon
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Flexible(child: _MiniAddDrinkButton()),
                AppSpacerW12,
                Container(
                  width: 32,
                  height: 32,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.neutral300,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: AppColors.primary500Dark.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: AppIcon(
                    'assets/images/webp/img_cup_widget_water.webp',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SMALL WIDGET B — Amount + remaining + progress bar
// =============================================================================
class _SmallWidgetB extends StatelessWidget {
  const _SmallWidgetB();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      double progress = 0.9;
      int currentMl = 1800;
      int goalMl = 2000;
      if (Get.isRegistered<TodayController>()) {
        final controller = Get.find<TodayController>();
        progress = controller.progress;
        currentMl = controller.currentIntakeMl.value;
        goalMl = controller.adjustedGoal;
      }
      final volumeUnit = Get.isRegistered<SettingsController>()
          ? Get.find<SettingsController>().volumeUnit.value
          : 'ml';
      final remaining = (goalMl - currentMl).clamp(0, goalMl);

      return Container(
        height: 162,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: AppColors.gradientWidgetB,
          border: Border.all(
            color: AppColors.primary500Dark.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: drop icon + amount
            Row(
              children: [
                AppIcon('assets/images/webp/img_water_widget.webp', size: 40),
                AppText(
                  UnitConverter.formatVolume(currentMl.toDouble(), volumeUnit),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            AppText(
              "remaining".trParams({
                'args1': UnitConverter.formatVolume(
                  remaining.toDouble(),
                  volumeUnit,
                ),
              }),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.basic400,
                fontWeight: FontWeight.w400,
              ),
            ),
            AppSpacerH4,
            AppRow(
              children: [
                AppText(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.basic500,
                  ),
                ),
                const SizedBox(width: 12),
                // Progress bar
                Expanded(
                  child: Stack(
                    children: [
                      // Background track
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.neutral300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      // Progress bar
                      FractionallySizedBox(
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Add Drink button
            AppSpacerH8,
            const Center(
              child: _MiniAddDrinkButton(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                gradient: LinearGradient(
                  begin: Alignment(-2, 0.7),
                  end: Alignment(2, -0.7),
                  colors: [
                    AppColors.onboardingGradientStart,
                    AppColors.onboardingGradientEnd,
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// =============================================================================
// MEDIUM WIDGET A — Reminder countdown with glass illustration
// =============================================================================
class _MediumWidgetA extends StatelessWidget {
  const _MediumWidgetA();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodayController>();
    return Container(
      height: 162,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.gradientWidgetC,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Wave decoration at bottom
          // Positioned(
          //   left: 0,
          //   right: 0,
          //   bottom: 0,
          //   height: 100,
          //   child: ClipRRect(
          //     borderRadius: const BorderRadius.vertical(
          //       bottom: Radius.circular(20),
          //     ),
          //     child: CustomPaint(painter: _WaveDecorationPainter()),
          //   ),
          // ),
          Column(
            children: [
              // Glass illustration
              AppIcon(
                'assets/images/webp/img_time_widget_medium.webp',
                size: 68,
                autoMirror: true,
              ),
              // Percentage badge + reminder text
              Stack(
                alignment: Alignment.center,
                children: [
                  // Percentage badge
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Obx(() {
                      double progress = 0.45;
                      if (Get.isRegistered<TodayController>()) {
                        progress = Get.find<TodayController>().progress;
                      }
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          AppIcon(
                            'assets/images/svg/ic_bg_tag.svg',
                            size: 28,
                            autoMirror: true,
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 14),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppIcon(
                                  'assets/images/webp/img_water.webp',
                                  size: 24,
                                  autoMirror: true,
                                ),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  AppText(
                    'next_reminder'.trParams({
                      "args1": UnitConverter.formatTime(
                        controller.nextReminderTime.value,
                        Get.find<SettingsController>().timeFormat.value,
                      ),
                    }),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              AppSpacerH8,
              const _CountdownTimer(),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// COUNTDOWN TIMER — Flip-clock style digits
// =============================================================================
class _CountdownTimer extends StatefulWidget {
  const _CountdownTimer();

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  Timer? _timer;
  String _hours = '00';
  String _minutes = '00';
  String _seconds = '00';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    if (!Get.isRegistered<TodayController>()) return;

    final nextStr = Get.find<TodayController>().nextReminderTime.value;
    if (nextStr.isEmpty || !nextStr.contains(':')) {
      if (mounted) {
        setState(() {
          _hours = '00';
          _minutes = '00';
          _seconds = '00';
        });
      }
      return;
    }

    final parts = nextStr.split(':');
    final targetHour = int.tryParse(parts[0]) ?? 0;
    final targetMin = int.tryParse(parts[1]) ?? 0;

    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, targetHour, targetMin);
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }

    final diff = target.difference(now);
    if (diff.isNegative) {
      if (mounted) {
        setState(() {
          _hours = '00';
          _minutes = '00';
          _seconds = '00';
        });
      }
      return;
    }

    final h = (diff.inHours).toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');

    if (mounted) {
      setState(() {
        _hours = h;
        _minutes = m;
        _seconds = s;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppSpacerW6,
        _timerUnit(_hours, 'hour'),
        _colon(),
        _timerUnit(_minutes, 'minute'),
        _colon(),
        _timerUnit(_seconds, 'second'),
      ],
    );
  }

  Widget _colon() {
    return Column(
      children: [
        Container(
          height: 22,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: const Text(
            ':',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget _timerUnit(String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            _digitBox(value.isNotEmpty ? value[0] : '0'),
            AppSpacerW2,
            _digitBox(value.length > 1 ? value[1] : '0'),
          ],
        ),
        const SizedBox(height: 4),
        AppText(
          label.tr.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _digitBox(String digit) {
    return Container(
      width: 18,
      height: 22,
      decoration: BoxDecoration(
        color: AppColors.basic200,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// =============================================================================
// MEDIUM WIDGET B — Today's intake with progress ring + quick add buttons
// =============================================================================
class _MediumWidgetB extends StatelessWidget {
  const _MediumWidgetB();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.gradientWidgetD,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress ring
          SizedBox(
            width: 120,
            height: 120,
            child: Obx(() {
              double progress = 0.9;
              if (Get.isRegistered<TodayController>()) {
                progress = Get.find<TodayController>().progress;
              }
              return Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(120, 120),
                    painter: _FullCircleProgressPainter(progress: progress),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(width: 16),
          // Right side: text + quick add buttons
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  "today_s_intake".tr,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.basic500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Obx(() {
                  int currentMl = 1800;
                  int goalMl = 2000;
                  if (Get.isRegistered<TodayController>()) {
                    final controller = Get.find<TodayController>();
                    currentMl = controller.currentIntakeMl.value;
                    goalMl = controller.adjustedGoal;
                  }
                  final volumeUnit = Get.isRegistered<SettingsController>()
                      ? Get.find<SettingsController>().volumeUnit.value
                      : 'ml';
                  return AppRow(
                    children: [
                      AppText(
                        UnitConverter.formatVolume(
                          currentMl.toDouble(),
                          volumeUnit,
                        ),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: AppColors.basic500,
                        ),
                      ),
                      AppText(
                        ' / ${UnitConverter.formatVolume(goalMl.toDouble(), volumeUnit)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.basic400,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                }),
                AppSpacerH8,
                _buildQuickAddGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddGrid() {
    final items = [
      ('assets/images/svg/ic_water_capacity_150.svg', 150.0),
      ('assets/images/svg/ic_water_capacity_200.svg', 200.0),
      ('assets/images/svg/ic_water_capacity_300.svg', 300.0),
      ('assets/images/svg/ic_water_capacity_500.svg', 500.0),
      ('assets/images/svg/ic_water_capacity_700.svg', 700.0),
      ('assets/images/svg/ic_edit_water.svg', -1.0),
    ];
    final volumeUnit = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>().volumeUnit.value
        : 'ml';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _quickAddBtn(
                items[0].$1,
                UnitConverter.formatVolume(items[0].$2, volumeUnit),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _quickAddBtn(
                items[1].$1,
                UnitConverter.formatVolume(items[1].$2, volumeUnit),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _quickAddBtn(
                items[2].$1,
                UnitConverter.formatVolume(items[2].$2, volumeUnit),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _quickAddBtn(
                items[3].$1,
                UnitConverter.formatVolume(items[3].$2, volumeUnit),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _quickAddBtn(
                items[4].$1,
                UnitConverter.formatVolume(items[4].$2, volumeUnit),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(child: _quickAddBtn(items[5].$1, '')),
          ],
        ),
      ],
    );
  }

  Widget _quickAddBtn(String icon, String label) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(
            icon,
            size: label.isNotEmpty ? 12 : 16,
            tint: AppColors.basic500,
          ),
          if (label.isNotEmpty)
            AppText(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.basic500,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// LARGE WIDGET — Progress bar + drink history + quick add
// =============================================================================
class _LargeWidget extends StatelessWidget {
  const _LargeWidget();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      double progress = 0.9;
      int currentMl = 1800;
      int goalMl = 2000;
      if (Get.isRegistered<TodayController>()) {
        final controller = Get.find<TodayController>();
        progress = controller.progress;
        currentMl = controller.currentIntakeMl.value;
        goalMl = controller.adjustedGoal;
      }

      final records = <DrinkRecord>[];
      if (Get.isRegistered<HistoryController>()) {
        final historyCtrl = Get.find<HistoryController>();
        final sorted = historyCtrl.dayRecords.toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        records.addAll(sorted.take(2));
      }

      final volumeUnit = Get.isRegistered<SettingsController>()
          ? Get.find<SettingsController>().volumeUnit.value
          : 'ml';
      final timeFormat = Get.isRegistered<SettingsController>()
          ? Get.find<SettingsController>().timeFormat.value
          : '24h';

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: AppColors.gradientWidgetE,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Percentage + progress bar
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                AppSpacerW8,
                Expanded(
                  child: Stack(
                    children: [
                      // Background track
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.basic200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      // Progress bar with gradient
                      FractionallySizedBox(
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0094FF), Color(0xFF00E0FF)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacerH4,
            AppRow(
              children: [
                AppText(
                  "today_s_intake".tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.basic500,
                  ),
                ),
                AppSpacerW2,
                AppText(
                  UnitConverter.formatVolume(currentMl.toDouble(), volumeUnit),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.basic500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                AppText(
                  ' / ${UnitConverter.formatVolume(goalMl.toDouble(), volumeUnit)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.basic300,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            AppSpacerH12,
            if (records.isEmpty) ...[
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: AppText(
                    'no_records_today'.tr,
                    style: TextStyle(
                      color: AppColors.basic300,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ] else
              ...records.map((r) {
                final type = DrinkType.values.firstWhere(
                  (t) => t.name == r.drinkType,
                  orElse: () => DrinkType.water,
                );
                final color = _getDrinkColor(type);
                final timeStr = UnitConverter.formatTime(
                  '${r.timestamp.hour.toString().padLeft(2, '0')}:${r.timestamp.minute.toString().padLeft(2, '0')}',
                  timeFormat,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _drinkHistoryItem(
                    imagePath: type.imagePath,
                    iconColor: color,
                    name: type.label,
                    amount: UnitConverter.formatVolume(
                      r.originalAmountMl > 0
                          ? r.originalAmountMl.toDouble()
                          : r.amountMl.toDouble(),
                      volumeUnit,
                    ),
                    time: timeStr,
                  ),
                );
              }),
            AppSpacerH12,
            // Quick add buttons 3x2 grid
            _buildQuickAddGrid(),
          ],
        ),
      );
    });
  }

  Color _getDrinkColor(DrinkType type) {
    switch (type) {
      case DrinkType.water:
        return const Color(0xFF4FC3F7);
      case DrinkType.milk:
        return const Color(0xFFFFF9C4);
      case DrinkType.tea:
        return const Color(0xFFFFCCBC);
      case DrinkType.juice:
        return const Color(0xFFFFE082);
      case DrinkType.soup:
        return const Color(0xFFC5E1A5);
      case DrinkType.coffee:
        return const Color(0xFFBCAAA4);
      case DrinkType.beer:
        return const Color(0xFFFFD54F);
      case DrinkType.wine:
        return const Color(0xFFEF9A9A);
      case DrinkType.strongDrinks:
        return const Color(0xFFE57373);
    }
  }

  Widget _drinkHistoryItem({
    required String imagePath,
    required Color iconColor,
    required String name,
    required String amount,
    required String time,
  }) {
    return Row(
      children: [
        // Drink icon
        Container(
          width: 36,
          height: 36,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
        AppText(
          name.tr.capitalizeFirst ?? name.tr,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        AppText(
          amount,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary500Dark,
          ),
        ),
        const SizedBox(width: 10),
        AppText(
          time.tr,
          modifier: Modifier.background(
            color: AppColors.basic100,
            radius: 100,
          ).padding(horizontal: 8, vertical: 8),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w400,
            color: AppColors.basic500,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAddGrid() {
    final items = [
      ('assets/images/svg/ic_water_capacity_150.svg', 150.0),
      ('assets/images/svg/ic_water_capacity_200.svg', 200.0),
      ('assets/images/svg/ic_water_capacity_300.svg', 300.0),
      ('assets/images/svg/ic_water_capacity_500.svg', 500.0),
      ('assets/images/svg/ic_water_capacity_700.svg', 700.0),
      ('assets/images/svg/ic_edit_water.svg', -1.0),
    ];

    final volumeUnit = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>().volumeUnit.value
        : 'ml';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _quickAddBtn(
                items[0].$1,
                UnitConverter.formatVolume(items[0].$2, volumeUnit),
              ),
            ),
            AppSpacerW8,
            Expanded(
              child: _quickAddBtn(
                items[1].$1,
                UnitConverter.formatVolume(items[1].$2, volumeUnit),
              ),
            ),
            AppSpacerW8,
            Expanded(
              child: _quickAddBtn(
                items[2].$1,
                UnitConverter.formatVolume(items[2].$2, volumeUnit),
              ),
            ),
          ],
        ),
        AppSpacerH8,
        Row(
          children: [
            Expanded(
              child: _quickAddBtn(
                items[3].$1,
                UnitConverter.formatVolume(items[3].$2, volumeUnit),
              ),
            ),
            AppSpacerW8,
            Expanded(
              child: _quickAddBtn(
                items[4].$1,
                UnitConverter.formatVolume(items[4].$2, volumeUnit),
              ),
            ),
            AppSpacerW8,
            Expanded(
              child: _quickAddBtn(
                items[5].$1,
                items[5].$2 < 0
                    ? 'custom'.tr
                    : UnitConverter.formatVolume(items[5].$2, volumeUnit),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickAddBtn(String icon, String label) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(icon, size: 24, tint: AppColors.basic500),
          AppSpacerH4,
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.basic500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CUSTOM PAINTERS
// =============================================================================

/// Full circle progress ring for Medium Widget B
class _FullCircleProgressPainter extends CustomPainter {
  final double progress;
  _FullCircleProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const trackStrokeWidth = 16.0;
    const progressStrokeWidth = 8.0;
    final radius = (size.width - trackStrokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (progress > 0) {
      const startAngle = -pi / 2;
      final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);

      // Outer background only follows the progress
      final trackPaint = Paint()
        ..color = AppColors.basic300
        ..style = PaintingStyle.stroke
        ..strokeWidth = trackStrokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);

      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = progressStrokeWidth
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      canvas.drawArc(rect, startAngle, sweepAngle, false, shadowPaint);

      final progressPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = progressStrokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FullCircleProgressPainter old) =>
      old.progress != progress;
}

class _MiniAddDrinkButton extends StatelessWidget {
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;

  const _MiniAddDrinkButton({this.gradient, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary500Dark.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient:
              gradient ??
              const LinearGradient(
                begin: Alignment(-2, 0.7),
                end: Alignment(2, -0.7),
                colors: [
                  AppColors.onboardingButtonStart,
                  AppColors.onboardingButtonEnd,
                ],
              ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Tiny Bubbles
            Positioned(left: 4, top: 10, child: _buildBubble(6)),
            Positioned(left: 10, bottom: -2, child: _buildBubble(8)),
            Positioned(right: 8, top: 4, child: _buildBubble(4)),
            Positioned(right: 2, bottom: 10, child: _buildBubble(5)),

            // Content
            Padding(
              padding:
                  padding ??
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: AppText(
                        'add_drink'.tr,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.1),
      ),
      child: Stack(
        children: [
          Positioned(
            left: size * 0.2,
            top: size * 0.2,
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

