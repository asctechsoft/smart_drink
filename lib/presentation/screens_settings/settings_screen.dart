import 'package:dsp_base/app_localize.dart';
import 'package:dsp_base/app_material.dart';
import 'package:waternudge/controller/auth_controller.dart';
import 'package:waternudge/controller/settings_controller.dart';
import 'package:waternudge/controller/user_profile_controller.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';
import 'package:waternudge/utils/unit_converter.dart';
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

    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              // ── Header ──
              _buildHeader(context),
              const SizedBox(height: 8),
              // ── User card ──
              _UserCard(),
              const SizedBox(height: 24),
              // ── Section: CÁ NHÂN ──
              _SectionTitle(label: 'section_personal'.tr),
              const SizedBox(height: 10),
              _SectionCard(
                children: [
                  Obx(() {
                    final gender = profileCtrl.profile.value.gender;
                    return _SettingsTile(
                      iconData: Icons.person_outline_rounded,
                      title: 'gender'.tr,
                      subtitle: 'settings_gender_desc'.tr,
                      value: gender.tr,
                      onTap: () => showGenderSheet(context),
                    );
                  }),
                  _Divider(),
                  Obx(() {
                    final weather = profileCtrl.profile.value.weatherCondition;
                    return _SettingsTile(
                      iconData: Icons.wb_cloudy_outlined,
                      title: 'weather'.tr,
                      subtitle: 'settings_weather_desc'.tr,
                      value: weather.tr,
                      onTap: () => showWeatherSheet(context),
                    );
                  }),
                  _Divider(),
                  Obx(() {
                    final p = profileCtrl.profile.value;
                    final String goalVal;
                    if (p.volumeUnit == 'oz') {
                      goalVal =
                          '${UnitConverter.mlToOz(p.dailyGoalMl.toDouble()).toStringAsFixed(1)} oz';
                    } else if (p.dailyGoalMl >= 1000) {
                      goalVal =
                          '${(p.dailyGoalMl / 1000).toStringAsFixed(1)} L';
                    } else {
                      goalVal = '${p.dailyGoalMl} ml';
                    }
                    return _SettingsTile(
                      iconData: Icons.local_drink_outlined,
                      title: 'daily_goal'.tr,
                      subtitle: 'settings_daily_goal_desc'.tr,
                      value: goalVal,
                      onTap: () => showDailyGoalSheet(context),
                    );
                  }),
                  _Divider(),
                  Obx(() {
                    final p = profileCtrl.profile.value;
                    final heightVal = '${p.height.round()} ${p.heightUnit}';
                    return _SettingsTile(
                      iconData: Icons.straighten_rounded,
                      title: 'height'.tr,
                      subtitle: 'settings_height_desc'.tr,
                      value: heightVal,
                      onTap: () => showHeightSheet(context),
                    );
                  }),
                  _Divider(),
                  Obx(() {
                    final p = profileCtrl.profile.value;
                    final weightVal = '${p.weight.round()} ${p.weightUnit}';
                    return _SettingsTile(
                      iconData: Icons.monitor_weight_outlined,
                      title: 'weight'.tr,
                      subtitle: 'settings_weight_desc'.tr,
                      value: weightVal,
                      onTap: () => showWeightSheet(context),
                    );
                  }),
                  _Divider(),
                  Obx(() {
                    final vol = settingsCtrl.volumeUnit.value;
                    final wt = settingsCtrl.weightUnit.value;
                    final ht = profileCtrl.profile.value.heightUnit;
                    return _SettingsTile(
                      svgPath: 'assets/images/svg/ic_unit.svg',
                      title: 'units'.tr,
                      subtitle: 'settings_units_desc'.tr,
                      value: '$vol / $wt / $ht',
                      onTap: () => showUnitsSheet(context),
                    );
                  }),
                  _Divider(),
                  Obx(() {
                    settingsCtrl.language.value;
                    return _SettingsTile(
                      iconData: Icons.language_rounded,
                      title: 'language'.tr,
                      subtitle: 'settings_language_desc'.tr,
                      value: CommLocalize.getLocaleName(
                        CommLocalize.getAppLocale(),
                      ),
                      onTap: () => showLanguageSheet(context),
                    );
                  }),
                  _Divider(),
                  Obx(() {
                    final wakeUp = profileCtrl.profile.value.wakeUpTime;
                    return _SettingsTile(
                      iconData: Icons.wb_sunny_outlined,
                      title: 'what_time_do_you_wake_up'.tr,
                      subtitle: 'settings_wakeup_desc'.tr,
                      value: wakeUp,
                      onTap: () => showWakeupSheet(context),
                    );
                  }),
                  _Divider(),
                  Obx(() {
                    final bedTime = profileCtrl.profile.value.bedTime;
                    return _SettingsTile(
                      iconData: Icons.nightlight_round,
                      title: 'bedtime'.tr,
                      subtitle: 'settings_bedtime_desc'.tr,
                      value: bedTime,
                      onTap: () => showBedtimeSheet(context),
                    );
                  }),
                  _Divider(),
                  _SettingsTile(
                    svgPath: 'assets/images/svg/ic_theme.svg',
                    title: 'theme'.tr,
                    subtitle: 'settings_theme_desc'.tr,
                    value: 'Dark',
                    hideChevron: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // ── Section: KHÁC ──
              _SectionTitle(label: 'section_other'.tr),
              const SizedBox(height: 10),
              _SectionCard(
                children: [
                  _SettingsTile(
                    iconData: Icons.shield_outlined,
                    title: 'settings_privacy'.tr,
                    subtitle: 'settings_privacy_desc'.tr,
                    onTap: () {},
                  ),
                  _Divider(),
                  _SettingsTile(
                    iconData: Icons.help_outline_rounded,
                    title: 'settings_help'.tr,
                    subtitle: 'settings_help_desc'.tr,
                    onTap: () {},
                  ),
                  _Divider(),
                  Obx(
                    () => settingsCtrl.isRated.value
                        ? const SizedBox.shrink()
                        : Column(
                            children: [
                              _SettingsTile(
                                svgPath: 'assets/images/svg/ic_rate.svg',
                                title: 'rate_app'.tr,
                                subtitle: 'settings_rate_desc'.tr,
                                onTap: () => showRateAppDialog(context),
                              ),
                              _Divider(),
                            ],
                          ),
                  ),
                  _SettingsTile(
                    iconData: Icons.info_outline_rounded,
                    title: 'settings_about'.tr,
                    subtitle: 'settings_about_desc'.tr,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'settings'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'settings_subtitle'.tr,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(5, 0),
            child: Image.asset(
              'assets/images/webp/img_bg_setting.webp',
              height: 155,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── User Card ────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final auth = AuthController.to;
      final loggedIn = auth.isLoggedIn;

      return GestureDetector(
        onTap: loggedIn ? null : () => auth.signInWithGoogle(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              _buildAvatar(auth, loggedIn),
              const SizedBox(width: 12),
              Expanded(
                child: loggedIn
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            auth.email,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Login with Google',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'settings_login_desc'.tr,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
              ),
              if (loggedIn)
                GestureDetector(
                  onTap: () => auth.signOut(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Text(
                      'Sign out',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAvatar(AuthController auth, bool loggedIn) {
    if (loggedIn && auth.photoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          auth.photoUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultAvatar(),
        ),
      );
    }
    return _defaultAvatar();
  }

  Widget _defaultAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SvgPicture.asset('assets/images/svg/ic_google.svg'),
      ),
    );
  }
}

// ─── Section Title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(children: children),
    );
  }
}

// ─── Divider ──────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.white.withValues(alpha: 0.1),
      indent: 68,
      endIndent: 0,
    );
  }
}

// ─── Settings Tile ────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final String? svgPath;
  final IconData? iconData;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  final bool hideChevron;

  const _SettingsTile({
    this.svgPath,
    this.iconData,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.hideChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
          child: Row(
            children: [
              _buildIconBox(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF57DCC0).withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    value!,
                    style: const TextStyle(
                      color: Color(0xFF57DCC0),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              if (!hideChevron) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF96D2A8),
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconBox() {
    const iconColor = Color(0xFF96D2A8);
    Widget icon;
    if (svgPath != null) {
      icon = SvgPicture.asset(
        svgPath!,
        width: 20,
        height: 20,
        colorFilter: const ColorFilter.mode(iconColor, BlendMode.srcIn),
      );
    } else {
      icon = Icon(iconData, size: 24, color: iconColor);
    }
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(child: icon),
    );
  }
}
