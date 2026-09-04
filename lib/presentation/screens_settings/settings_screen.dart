import 'package:dsp_base/app_localize.dart';
import 'package:dsp_base/app_material.dart';
import 'package:waternudge/controller/auth_controller.dart';
import 'package:waternudge/controller/reminder_controller.dart';
import 'package:waternudge/controller/settings_controller.dart';
import 'package:waternudge/controller/user_profile_controller.dart';
import 'package:waternudge/presentation/common_components/auth_loading_overlay.dart';
import 'package:waternudge/presentation/common_components/custom_switch.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';
import 'package:waternudge/utils/share_utils.dart';
import 'package:waternudge/utils/unit_converter.dart';
import 'package:waternudge/values/route_name.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'settings_bottom_sheets.dart';
import 'rate_app_dialog.dart';
import 'logout_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();
    final profileCtrl = Get.find<UserProfileController>();
    final reminderCtrl = Get.find<ReminderController>();

    return AuthLoadingOverlay(
      child: OnboardingBackground(
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

                // ── 1. DRINK ── things that affect hydration goal ──
                _SectionTitle(label: 'section_drink'.tr),
                const SizedBox(height: 10),
                _SectionCard(
                  children: [
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
                      final weather =
                          profileCtrl.profile.value.weatherCondition;
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
                  ],
                ),
                const SizedBox(height: 24),

                // ── 2. SCHEDULE ── daily rhythm & reminders ──
                _SectionTitle(label: 'section_schedule'.tr),
                const SizedBox(height: 10),
                _SectionCard(
                  children: [
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
                    Obx(() {
                      final napValue = reminderCtrl.napEnabled.value
                          ? '${reminderCtrl.napStart.value} - ${reminderCtrl.napEnd.value}'
                          : 'off'.tr;
                      return _SettingsTile(
                        iconData: Icons.bedtime_outlined,
                        title: 'nap_time_range'.tr,
                        subtitle: 'settings_nap_desc'.tr,
                        value: napValue,
                        onTap: () => showNapScheduleSheet(context),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 24),

                // ── 3. GENERAL ── app-wide settings ──
                _SectionTitle(label: 'section_general'.tr),
                const SizedBox(height: 10),
                _SectionCard(
                  children: [
                    // Master reminder toggle (moved here from the Reminder tab).
                    Obx(
                      () => _SettingsToggleTile(
                        iconData: Icons.notifications_outlined,
                        title: 'Bật nhắc nhở uống nước',
                        subtitle: 'Nhận thông báo nhắc uống nước mỗi ngày.',
                        value: reminderCtrl.enabled.value,
                        onChanged: (v) {
                          reminderCtrl.enabled.value = v;
                          reminderCtrl.saveSettings();
                        },
                      ),
                    ),
                    _Divider(),
                    // Reminder sound (moved here from the Reminder tab).
                    Obx(
                      () => _SettingsTile(
                        iconData: Icons.volume_up_outlined,
                        title: 'sound'.tr,
                        subtitle: 'settings_sound_desc'.tr,
                        value: soundDisplayName(reminderCtrl.soundEffect.value),
                        onTap: () => showSoundEffectSheet(context),
                      ),
                    ),
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
                        ).split(' (').first,
                        onTap: () => showLanguageSheet(context),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 24),

                // ── 4. SUPPORT & ABOUT ──
                _SectionTitle(label: 'section_support'.tr),
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
                      iconData: Icons.feedback_outlined,
                      title: 'settings_feedback'.tr,
                      subtitle: 'settings_feedback_desc'.tr,
                      onTap: () => Get.toNamed(RouteName.feedback),
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
                      iconData: Icons.share_outlined,
                      title: 'settings_share'.tr,
                      subtitle: 'settings_share_desc'.tr,
                      onTap: () => ShareUtils.shareApp(context),
                    ),
                    // Logout at the very bottom, only when signed in
                    Obx(
                      () => AuthController.to.isLoggedIn
                          ? Column(
                              children: [
                                _Divider(),
                                _SettingsTile(
                                  iconData: Icons.logout_rounded,
                                  title: 'settings_logout'.tr,
                                  subtitle: 'settings_logout_desc'.tr,
                                  onTap: () => showLogoutConfirmDialog(context),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── App version ──
                Center(
                  child: Text(
                    'settings_about_desc'.tr,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
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

class _UserCard extends StatefulWidget {
  @override
  State<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<_UserCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _syncSpin;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _syncSpin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _syncSpin.dispose();
    super.dispose();
  }

  Future<void> _onSync() async {
    if (_syncing) return;
    final msg = 'sync_success'.tr; // capture before async
    setState(() => _syncing = true);
    _syncSpin.repeat();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    _syncSpin.stop();
    _syncSpin.reset();
    setState(() => _syncing = false);
    Get.showSnackbar(
      GetSnackBar(
        backgroundColor: Colors.transparent,
        snackPosition: SnackPosition.TOP,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        duration: const Duration(seconds: 3),
        messageText: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: kToolbarHeight),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: Color(0xFF57DCC0),
                ),
                const SizedBox(width: 8),
                Text(
                  msg,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
                  onTap: _onSync,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: AnimatedBuilder(
                      animation: _syncSpin,
                      builder: (_, child) => Transform.rotate(
                        angle: _syncSpin.value * 6.2832,
                        child: child,
                      ),
                      child: const Icon(
                        Icons.sync_rounded,
                        size: 20,
                        color: Colors.white70,
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
          errorBuilder: (_, _, _) => _defaultAvatar(),
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

// ─── Settings Toggle Tile ─────────────────────────────────────────────────────

class _SettingsToggleTile extends StatelessWidget {
  final IconData iconData;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggleTile({
    required this.iconData,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const iconColor = Color(0xFF96D2A8);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        children: [
          Container(
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
            child: Center(child: Icon(iconData, size: 24, color: iconColor)),
          ),
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
          const SizedBox(width: 8),
          CustomSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF57DCC0),
            trackColor: Colors.white.withValues(alpha: 0.2),
          ),
        ],
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

  const _SettingsTile({
    this.svgPath,
    this.iconData,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
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
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF96D2A8),
                size: 24,
              ),
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
