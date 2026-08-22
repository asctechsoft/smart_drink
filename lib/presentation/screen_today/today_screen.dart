import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/controller/today_controller.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/values/app_colors.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';

import 'package:get/get.dart';
import 'package:smartdrinkai/presentation/screen_today/components/today_header.dart';
import 'package:smartdrinkai/presentation/screen_today/components/drink_action_bar.dart';
import 'package:smartdrinkai/presentation/common_components/water_human_progress.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodayController>();
    return OnboardingBackground(
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

                // Figure fills the flexible middle; the top info overlays its
                // upper body and the remaining pill floats at the bottom, so
                // the whole screen fits without scrolling.
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6, bottom: 60),
                          child: Obx(
                            () => FittedBox(
                              fit: BoxFit.contain,
                              alignment: Alignment.topCenter,
                              child: WaterHumanProgress(
                                progress: controller.progress,
                                currentMl: controller.currentIntakeMl.value,
                                goalMl: controller.adjustedGoal,
                                volumeUnit: Get.find<SettingsController>()
                                    .volumeUnit
                                    .value,
                                width: 300,
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
                              _buildGoalStatus(controller, context),
                              Center(
                                child: _buildRemainingPill(controller, context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Obx(() => _buildStatusCards(controller, context)),
                ),
                const SizedBox(height: 12),
                // Drink action bar: +amount
                const DrinkActionBar(),
                const SizedBox(height: 4),
              ],
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
    final remaining = (goalMl - currentMl) > 0 ? (goalMl - currentMl) : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: ob.bgOption,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: ob.borderTabHistory, width: 1),
        boxShadow: ob.cardGlowShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          const SizedBox(width: 6),
          Icon(
            Icons.chevron_right_rounded,
            color: ob.textPrimary.withValues(alpha: 0.5),
            size: 18,
          ),
        ],
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

    TextStyle labelStyle() =>
        TextStyle(fontSize: 13, color: ob.textPrimary.withValues(alpha: 0.7));
    TextStyle valueStyle() => TextStyle(
      fontSize: 15,
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
              svgIcon: controller.currentAmountIcon,
              label: 'Loại cốc',
              onTap: () => showCupSizeSheet(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              emoji: '🔥',
              label: 'Streak',
              value: '${controller.streakDays.value}',
              unit: 'ngày',
              bg: ob.bgOption,
              border: ob.borderTabHistory,
              textColor: ob.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionCard(
              imagePath: controller.selectedDrinkType.value.imagePath,
              label: 'menu',
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
    this.emoji,
    required this.label,
    required this.value,
    required this.unit,
    required this.bg,
    required this.border,
    required this.textColor,
  });

  final String? emoji;
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
        boxShadow: AppColors.cardGlowShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: Center(
                  child: Text(
                    emoji ?? '',
                    style: const TextStyle(fontSize: 13, height: 1),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  height: 1,
                  color: textColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textColor,
              height: 1,
            ),
          ),
          if (unit.isNotEmpty)
            Text(
              unit,
              style: TextStyle(
                fontSize: 12,
                height: 1,
                color: textColor.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Action card (cup size / menu) ────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    this.svgIcon,
    this.imagePath,
    required this.label,
    required this.onTap,
  });

  final String? svgIcon;
  final String? imagePath;
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
          color: ob.bgOption,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ob.borderTabHistory, width: 1),
          boxShadow: AppColors.cardGlowShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath!,
                width: 26,
                height: 26,
                fit: BoxFit.contain,
              )
            else if (svgIcon != null)
              AppIcon(svgIcon!, size: 26, tint: ob.iconPill),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: ob.textPrimary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
