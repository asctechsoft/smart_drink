import 'package:dsp_base/app_localize.dart';
import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/controller/user_profile_controller.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/utils/unit_converter.dart';
import 'package:smartdrinkai/values/app_colors.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:smartdrinkai/values/route_name.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'settings_bottom_sheets.dart';
import 'rate_app_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();
    final profileCtrl = Get.find<UserProfileController>();
    final ob = OnboardingTheme.of(context);
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation:
              0, // Quan trọng: tắt hiệu ứng đổi màu Material 3 khi scroll
          centerTitle: true,
          title: AppText(
            'settings'.tr,
            style: TextStyle(
              color: ob.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 0 + 10,
          ),
          child: SafeArea(
            bottom: false,
            child: AppColumn(
              children: [
                // ── Scrollable content ──
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // Premium banner
                      _PremiumBanner(
                        onTap: () => Get.toNamed(RouteName.premium),
                      ),
                      AppSpacerH20,
                      // Widget
                      _SettingsTile(
                        icon: 'assets/images/svg/ic_widget.svg',
                        title: 'widget'.tr,
                        onTap: () => Get.toNamed(RouteName.widgetPreview),
                      ),
                      AppSpacerH12,
                      // Gender
                      const _SectionTitle(title: 'personal_info'),
                      Obx(
                        () => _SettingsTile(
                          icon: 'assets/images/svg/ic_gender.svg',
                          title: 'gender'.tr,
                          value: profileCtrl.profile.value.gender
                              .toLowerCase()
                              .tr,
                          onTap: () => showGenderSheet(context),
                        ),
                      ),
                      Obx(
                        () => _SettingsTile(
                          icon: 'assets/images/svg/ic_weight.svg',
                          title: 'weight'.tr,
                          value:
                              '${profileCtrl.profile.value.weight.round()} ${profileCtrl.profile.value.weightUnit}',
                          onTap: () => showWeightSheet(context),
                        ),
                      ),
                      /* Obx(() {
                        final p = profileCtrl.profile.value;
                        final heightDisplay = p.heightUnit == 'm'
                            ? '${p.height.toStringAsFixed(2)} m'
                            : '${p.height.round()} cm';
                        return _SettingsTile(
                          icon: 'assets/images/svg/ic_height.svg',
                          title: 'height'.tr,
                          value: heightDisplay,
                          onTap: () => showHeightSheet(context),
                        );
                      }),
                      Obx(
                        () => _SettingsTile(
                          icon: 'assets/images/svg/ic_age.svg',
                          title: 'age'.tr,
                          value: '${profileCtrl.profile.value.age}',
                          onTap: () => showAgeSheet(context),
                        ),
                      ), */
                      Obx(() {
                        final p = profileCtrl.profile.value;
                        final goalDisplay = p.volumeUnit == 'oz'
                            ? '${UnitConverter.mlToOz(p.dailyGoalMl.toDouble()).round()} oz'
                            : '${p.dailyGoalMl} ml';
                        return _SettingsTile(
                          icon: 'assets/images/svg/ic_daily_goal.svg',
                          title: 'daily_goal'.tr,
                          value: goalDisplay,
                          onTap: () => showDailyGoalSheet(context),
                        );
                      }),
                      AppSpacerH12,
                      // General
                      const _SectionTitle(title: 'general'),
                      Obx(
                        () => _SettingsTile(
                          icon: 'assets/images/svg/ic_unit.svg',
                          title: 'units'.tr,
                          value:
                              '${settingsCtrl.volumeUnit.value}, ${settingsCtrl.weightUnit.value}',
                          onTap: () => showUnitsSheet(context),
                        ),
                      ),
                      Obx(() {
                        final format = settingsCtrl.timeFormat.value;
                        String display;
                        if (format == '12h') {
                          display = 'time_12_hour'.tr;
                        } else if (format == 'system') {
                          display = 'follow_the_system'.tr;
                        } else {
                          display = 'time_24_hour'.tr;
                        }
                        return _SettingsTile(
                          icon: 'assets/images/svg/ic_time.svg',
                          title: 'time_format'.tr,
                          value: display,
                          onTap: () => showTimeFormatSheet(context),
                        );
                      }),
                      AppSpacerH12,

                      // Settings
                      const _SectionTitle(title: 'settings'),
                      Obx(
                        () => _SettingsTile(
                          icon: 'assets/images/svg/ic_theme.svg',
                          title: 'theme'.tr,
                          value: settingsCtrl.themeMode.value.toLowerCase().tr,
                          onTap: () => Get.toNamed(RouteName.themeSelection),
                        ),
                      ),
                      Obx(() {
                        settingsCtrl.language.value;
                        return _SettingsTile(
                          icon: 'assets/images/svg/ic_language.svg',
                          title: 'language'.tr,
                          value: CommLocalize.getLocaleName(
                            CommLocalize.getAppLocale(),
                          ),
                          onTap: () => Get.toNamed(RouteName.languageSelection),
                        );
                      }),
                      AppSpacerH12,
                      // More
                      const _SectionTitle(title: 'more'),
                      Obx(
                        () => settingsCtrl.isRated.value
                            ? const SizedBox.shrink()
                            : _SettingsTile(
                                icon: 'assets/images/svg/ic_rate.svg',
                                title: 'rate_app'.tr,
                                onTap: () => showRateAppDialog(context),
                              ),
                      ),
                      _SettingsTile(
                        icon: 'assets/images/svg/ic_feedback.svg',
                        title: 'feedback'.tr,
                        onTap: () => Get.toNamed(RouteName.feedback),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Premium Banner ──────────────────────────────────────────────────────────

class _PremiumBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _PremiumBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        margin: const EdgeInsets.only(top: 10), // chừa chỗ cho icon nhô lên
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: AssetImage('assets/images/webp/img_IAP.webp'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Icon nhô ra trên banner
            Positioned(
              top: 0,
              child: Image.asset(
                'assets/images/webp/ic_diamond.webp',
                width: 90,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            // Text căn giữa dọc, lùi sang phải tránh icon
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(left: 80, right: 16),
                child: AppColumn(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: AppText(
                        'get_premium'.tr,
                        maxLines: 1,
                        style: TextStyle(
                          color: AppColors.basic500,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: AppText(
                        'unlock_all_features_and_remove_ads'.tr,
                        maxLines: 1,
                        style: TextStyle(
                          color: AppColors.basic500,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Title ───────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: AppText(
        title.tr,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: ob.textPrimary,
        ),
      ),
    );
  }
}

// ─── Settings Tile ───────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final String icon;
  final String title;
  final String? value;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: ob.bgOption,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SvgPicture.asset(icon, width: 22, height: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: AppText(
                    title.tr.capitalizeFirst!,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: ob.textPrimary,
                    ),
                  ),
                ),
                if (value != null)
                  AppText(
                    value!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ob.switchActive,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

