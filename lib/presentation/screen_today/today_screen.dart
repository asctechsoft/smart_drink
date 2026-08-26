import 'package:dsp_base/app_material.dart';
import 'package:waternudge/controller/settings_controller.dart';
import 'package:waternudge/controller/today_controller.dart';
import 'package:waternudge/controller/user_profile_controller.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';
import 'package:waternudge/presentation/screen_today/components/streak_dialog.dart';
import 'package:waternudge/values/app_colors.dart';
import 'package:waternudge/values/onboarding_theme.dart';

import 'package:get/get.dart';
import 'package:waternudge/presentation/screen_today/components/today_header.dart';
import 'package:waternudge/presentation/screen_today/components/drink_action_bar.dart';
import 'package:waternudge/presentation/common_components/water_human_progress.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  Worker? _streakWorker;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<TodayController>();
    _streakWorker = ever(controller.streakIncreasedEvent, (prev) {
      if (prev != null && mounted) {
        showStreakDialog(
          context,
          previousStreak: prev,
          currentStreak: controller.streakDays.value,
        );
      }
    });
  }

  @override
  void dispose() {
    _streakWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodayController>();
    // Decode the cup artwork ahead of time so opening the cup-size sheet
    // doesn't hitch on first image load.
    for (final p in TodayController.cupImages) {
      precacheImage(AssetImage(p), context);
    }
    // Cache the whole screen as one layer so that while a bottom sheet slides
    // up (and its scrim fades in), this screen isn't re-rasterised every frame
    // — that re-composite of the SVG body + gradient was the source of the jank.
    return RepaintBoundary(
      child: OnboardingBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 10,
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header
                  TodayHeader(),

                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 32),

                              child: SizedBox(
                                width: 260,
                                height: 320,
                                child: RepaintBoundary(
                                  child: Obx(
                                    () => FittedBox(
                                      fit: BoxFit.contain,
                                      child: WaterHumanProgress(
                                        progress: controller.progress,
                                        currentMl:
                                            controller.currentIntakeMl.value,
                                        goalMl: controller.adjustedGoal,
                                        volumeUnit:
                                            Get.find<SettingsController>()
                                                .volumeUnit
                                                .value,
                                        width: 300,
                                        isFemale:
                                            Get.find<UserProfileController>()
                                                .profile
                                                .value
                                                .gender ==
                                            'female',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Obx(() => _buildTopInfo(controller, context)),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Obx(
                            () => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // _buildGoalStatus(controller, context),
                                Center(
                                  child: _buildRemainingPill(
                                    controller,
                                    context,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Obx(() => _buildStatusCards(controller, context)),
                  ),
                  const SizedBox(height: 20),
                  // Drink action bar: +amount
                  const DrinkActionBar(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRemainingPill(TodayController controller, BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final currentMl = controller.currentIntakeMl.value;
    final goalMl = controller.adjustedGoal;

    // Three states: still short of goal, exactly done, or exceeded.
    final List<Widget> content;
    if (goalMl > 0 && currentMl > goalMl) {
      final pct = ((currentMl - goalMl) / goalMl * 100).round();
      content = [
        Text(
          'Vượt quá $pct%',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.error,
          ),
        ),
      ];
    } else if (goalMl > 0 && currentMl >= goalMl) {
      content = [
        const Text(
          'Hoàn thành mục tiêu',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.success,
          ),
        ),
      ];
    } else {
      final remaining = goalMl - currentMl;
      content = [
        Text(
          'Còn lại ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ob.textPrimary.withValues(alpha: 0.7),
          ),
        ),
        Text(
          '$remaining ml',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF67B5E2),
          ),
        ),
      ];
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: ob.cardGlowShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: content,
      ),
    );
  }

  /// Top-corner info: last drink (left) and daily goal (right).
  Widget _buildTopInfo(TodayController controller, BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final goalMl = controller.adjustedGoal;
    final lastDrink = controller.todayRecords.isNotEmpty
        ? controller.todayRecords.last
        : null;

    String lastTime = '--:--';
    String lastAmPm = '';
    if (lastDrink != null) {
      lastAmPm = lastDrink.timestamp.hour >= 12 ? 'chiều' : 'sáng';
      int h = lastDrink.timestamp.hour % 12;
      if (h == 0) h = 12;
      lastTime =
          '${h.toString().padLeft(2, '0')}:${lastDrink.timestamp.minute.toString().padLeft(2, '0')}';
    }

    TextStyle labelStyle() => TextStyle(
      fontSize: 16,
      color: Colors.white60,
      fontWeight: FontWeight.w600,
    );
    TextStyle valueStyle() => TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: ob.textPrimary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lần cuối', style: labelStyle()),
              const SizedBox(height: 2),
              Text(
                lastAmPm.isEmpty ? lastTime : '$lastTime $lastAmPm',
                style: valueStyle(),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Mục tiêu', style: labelStyle()),
              const SizedBox(height: 2),
              Text('$goalMl ml', style: valueStyle()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCards(TodayController controller, BuildContext context) {
    final ob = OnboardingTheme.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _ActionCard(
              imagePath: controller.currentCupImage,
              label: 'Loại cốc',
              onTap: () => showCupSizeSheet(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              iconWidget: Image.asset(
                'assets/images/webp/img_drink_streak.webp',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
              label: 'Streak',
              value: '${controller.streakDays.value}',
              unit: 'ngày',
              bg: Colors.white.withValues(alpha: 0.07),
              border: Colors.white.withValues(alpha: 0.1),
              textColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionCard(
              imagePath: controller.selectedDrinkType.value.imagePath,
              label: 'Menu',
              onTap: () => showDrinkTypeSheet(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStatus(TodayController controller, BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final currentMl = controller.currentIntakeMl.value;
    final goalMl = controller.adjustedGoal;

    if (currentMl < goalMl) return const SizedBox.shrink();
    final bool isExceeded = currentMl > goalMl;

    return AppRow(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppText(
          isExceeded ? 'exceeded_your_goal'.tr : 'goal_completed'.tr,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ob.textPrimary,
            letterSpacing: 0.9,
          ),
        ),
        if (isExceeded) ...[
          AppSpacerW2,
          AppText(
            '${(((currentMl / goalMl) - 1.0) * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ob.textReminderIcon,
              letterSpacing: 0.9,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    this.iconWidget,
    required this.label,
    required this.value,
    required this.unit,
    required this.bg,
    required this.border,
    required this.textColor,
  });

  final Widget? iconWidget;
  final String label;
  final String value;
  final String unit;
  final Color bg;
  final Color border;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 24, height: 24, child: Center(child: iconWidget)),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  height: 1,
                  color: Colors.white60,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  height: 1,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1,
                      color: Colors.white60,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Action card (cup size / menu) ────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.imagePath,
    required this.label,
    required this.onTap,
  });

  final String imagePath;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 26, height: 26, fit: BoxFit.contain),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white60,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
