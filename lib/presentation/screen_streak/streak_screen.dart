import 'package:dsp_base/app_material.dart';
import 'package:get/get.dart';
import 'package:smartdrinkai/controller/streak_controller.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/presentation/screen_streak/components/streak_calendar.dart';
import 'package:smartdrinkai/presentation/screen_streak/components/streak_hero_card.dart';
import 'package:smartdrinkai/presentation/screen_streak/components/streak_stat_card.dart';
import 'package:smartdrinkai/presentation/screen_streak/components/streak_week_overview.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';

class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StreakController>();
    final ob = OnboardingTheme.of(context);

    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            icon: AppIcon(
              'assets/images/svg/ic_back_left.svg',
              size: 24,
              tint: ob.textPrimary,
              autoMirror: true,
            ),
            onPressed: () => Get.back(),
          ),
          centerTitle: false,
          title: AppText(
            'drinking_streak'.tr,
            style: TextStyle(
              color: ob.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StreakHeroCard(controller: controller),
                const SizedBox(height: 14),
                // IntrinsicHeight bounds the row so the two cards can stretch
                // to a shared height inside the unbounded scroll view.
                // IntrinsicHeight(
                //   child: Obx(
                //     () => Row(
                //       crossAxisAlignment: CrossAxisAlignment.stretch,
                //       children: [
                //         Expanded(
                //           child: StreakStatCard(
                //             title: 'streak_total_days_tracked'.tr,
                //             value: '${controller.totalDaysTracked.value}',
                //             iconPath: 'assets/images/webp/ic_calendar.webp',
                //           ),
                //         ),
                //         const SizedBox(width: 12),
                //         Expanded(
                //           child: StreakStatCard(
                //             title: 'streak_longest_streak'.tr,
                //             value: '${controller.longestStreak.value}',
                //             iconPath: 'assets/images/webp/ic_cup_streak.webp',
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 14),
                StreakCalendar(controller: controller),
                const SizedBox(height: 14),
                StreakWeekOverview(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
