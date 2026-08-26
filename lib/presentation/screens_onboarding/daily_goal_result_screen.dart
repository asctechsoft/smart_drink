import 'package:dsp_base/app_material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternudge/controller/user_profile_controller.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';
import 'package:waternudge/presentation/common_components/primary_button.dart';
import 'package:waternudge/presentation/common_components/stagger_reveal.dart';
import 'package:waternudge/values/app_colors.dart';
import 'package:waternudge/values/onboarding_theme.dart';
import 'package:waternudge/values/route_name.dart';

/// Shown right after the "building schedule" animation completes. Presents the
/// calculated daily water goal + the inputs it was derived from, then sends the
/// user to the home screen.
class DailyGoalResultScreen extends StatelessWidget {
  const DailyGoalResultScreen({super.key});

  static const Map<String, String> _activityLabels = {
    'sedentary': 'Ít vận động',
    'light_active': 'Vận động nhẹ',
    'moderate_active': 'Trung bình',
    'very_active': 'Vận động nhiều',
  };

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final profile = Get.find<UserProfileController>().profile.value;

    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: StaggerColumn(
                    children: [
                      const SizedBox(height: 8),
                      _backButton(ob),
                      const SizedBox(height: 4),
                      Image.asset(
                        'assets/images/webp/img_daily_success.webp',
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mục tiêu hàng ngày của bạn',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: ob.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Dựa trên thông tin bạn đã cung cấp, lượng nước '
                        'khuyến nghị mỗi ngày của bạn là:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: ob.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _goalNumber(ob, profile.dailyGoalMl),
                      const SizedBox(height: 16),
                      Image.asset(
                        'assets/images/webp/img_daily_cup.webp',
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      _statsCard(ob, profile),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: StaggerReveal(
                  index: 8,
                  child: PrimaryButton(
                    text: 'Tuyệt vời! Bắt đầu nào',
                    width: double.infinity,
                    useGradient: true,
                    trailing: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.basic500,
                      size: 20,
                    ),
                    onPressed: () => Get.offAllNamed(RouteName.home),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backButton(OnboardingTheme ob) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => Get.back(),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Icon(Icons.chevron_left_rounded, color: ob.textPrimary),
        ),
      ),
    );
  }

  Widget _goalNumber(OnboardingTheme ob, int goalMl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$goalMl',
          style: const TextStyle(
            fontSize: 64,
            height: 1,
            fontWeight: FontWeight.w900,
            color: AppColors.accentTeal,
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'ml / ngày',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ob.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statsCard(OnboardingTheme ob, dynamic profile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          _statTile(
            ob,
            icon: Icons.person_rounded,
            color: const Color(0xFF4FA9FF),
            label: 'Cân nặng',
            value: '${profile.weight.round()} ${profile.weightUnit}',
          ),
          _statDivider(),
          _statTile(
            ob,
            icon: Icons.straighten_rounded,
            color: const Color(0xFF57DCC0),
            label: 'Chiều cao',
            value: '${profile.height.round()} ${profile.heightUnit}',
          ),
          _statDivider(),
          _statTile(
            ob,
            icon: Icons.favorite_rounded,
            color: const Color(0xFFA98BFF),
            label: 'Mức độ hoạt động',
            value: _activityLabels[profile.activityLevel] ?? 'Trung bình',
          ),
        ],
      ),
    );
  }

  Widget _statDivider() => Container(
    width: 1,
    height: 44,
    color: Colors.white.withValues(alpha: 0.1),
  );

  Widget _statTile(
    OnboardingTheme ob, {
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: ob.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: ob.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
