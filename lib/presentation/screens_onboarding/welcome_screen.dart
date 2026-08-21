import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/values/app_colors.dart';
import 'package:smartdrinkai/values/route_name.dart';
import 'package:get/get.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildHeroImage(),
                      const SizedBox(height: 24),
                      _buildTitle(context),
                      const SizedBox(height: 8),
                      _buildDivider(),
                      const SizedBox(height: 12),
                      _buildSubtitle(),
                      const SizedBox(height: 28),
                      _buildFeatureRow(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: PrimaryButton(
                  width: double.infinity,
                  text: 'welcome_start_btn'.tr,
                  onPressed: () => Get.toNamed(RouteName.onboardingGender),
                  useGradient: true,
                  trailing: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.btnCyanText.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.btnCyanText,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return SizedBox(
      height: 300,
      child: Image.asset(
        'assets/images/webp/img_bg_wellcome.webp',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final title1 = 'welcome_title_1'.tr;
    final title2 = 'welcome_title_2'.tr;
    final keyword = 'welcome_title_keyword'.tr;

    final idx = title2.indexOf(keyword);
    final beforeKw = idx >= 0 ? title2.substring(0, idx) : title2;
    final afterKw = idx >= 0 ? title2.substring(idx + keyword.length) : '';

    const titleStyle = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      height: 1.25,
    );

    return Column(
      children: [
        Text(title1, style: titleStyle, textAlign: TextAlign.left),
        Align(
          alignment: Alignment.centerLeft,
          child: RichText(
            text: TextSpan(
              style: titleStyle,
              children: [
                TextSpan(text: beforeKw),
                TextSpan(
                  text: keyword,
                  style: titleStyle.copyWith(
                    color: const Color(0xFF57DCC0),
                  ),
                ),
                TextSpan(text: afterKw),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 40,
        height: 2.5,
        decoration: BoxDecoration(
          color: const Color(0xFF57DCC0),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'welcome_subtitle'.tr,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white70,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildFeatureRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _FeatureItem(
          icon: Icons.notifications_active_outlined,
          title: 'welcome_feat_remind_title'.tr,
          desc: 'welcome_feat_remind_desc'.tr,
        ),
        _FeatureItem(
          icon: Icons.bar_chart_rounded,
          title: 'welcome_feat_track_title'.tr,
          desc: 'welcome_feat_track_desc'.tr,
        ),
        _FeatureItem(
          icon: Icons.favorite_border_rounded,
          title: 'welcome_feat_habit_title'.tr,
          desc: 'welcome_feat_habit_desc'.tr,
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(icon, color: const Color(0xFF57DCC0), size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          desc,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white60,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
