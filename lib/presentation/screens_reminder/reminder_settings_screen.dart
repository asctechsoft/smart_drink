import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/reminder_controller.dart';
import 'package:smartdrinkai/models/data_models/reminder_schedule.dart';
import 'package:smartdrinkai/presentation/common_components/custom_switch.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';

class ReminderSettingsPage extends StatelessWidget {
  const ReminderSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ReminderController>();

    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Builder(builder: (context) {
          final ob = OnboardingTheme.of(context);
          return SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 10,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(ctrl: ctrl, ob: ob),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _BannerCard(ctrl: ctrl, ob: ob),
                          const SizedBox(height: 24),
                          _DailySection(ctrl: ctrl, ob: ob),
                          const SizedBox(height: 16),
                          _SettingsSection(ctrl: ctrl, ob: ob),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final ReminderController ctrl;
  final OnboardingTheme ob;

  const _Header({required this.ctrl, required this.ob});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Nhắc nhở',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: ob.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showAddDialog(context, ctrl),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ob.bgOption,
                border: Border.all(color: ob.borderTabHistory, width: 1),
              ),
              child: Icon(Icons.add, size: 20, color: ob.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Banner Card ─────────────────────────────────────────────────────────────

class _BannerCard extends StatelessWidget {
  final ReminderController ctrl;
  final OnboardingTheme ob;

  const _BannerCard({required this.ctrl, required this.ob});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ob.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ob.accent.withValues(alpha: 0.20),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ob.accent.withValues(alpha: 0.15),
              border: Border.all(
                color: ob.accent.withValues(alpha: 0.30),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.water_drop_outlined,
              size: 34,
              color: ob.accent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đừng quên uống nước nhé!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ob.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Đặt nhắc nhở để duy trì thói quen uống nước đều đặn mỗi ngày.',
                  style: TextStyle(
                    fontSize: 11,
                    color: ob.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _showAddDialog(context, ctrl),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 7,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: ob.accent,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'THÊM NHẮC NHỞ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
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

// ─── Daily Reminders Section ─────────────────────────────────────────────────

class _DailySection extends StatelessWidget {
  final ReminderController ctrl;
  final OnboardingTheme ob;

  const _DailySection({required this.ctrl, required this.ob});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final schedules = ctrl.standardSchedules;
      return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nhắc nhở hàng ngày',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: ob.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: ob.bgOption,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ob.borderReminderPill, width: 1),
          ),
          child: Column(
            children: [
              for (int i = 0; i < schedules.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    color: ob.divider,
                    indent: 68,
                    endIndent: 0,
                  ),
                _ScheduleItem(schedule: schedules[i], ctrl: ctrl, ob: ob),
              ],
            ],
          ),
        ),
      ],
    );
    });
  }
}

// ─── Schedule Item ────────────────────────────────────────────────────────────

class _ScheduleItem extends StatelessWidget {
  final ReminderSchedule schedule;
  final ReminderController ctrl;
  final OnboardingTheme ob;

  const _ScheduleItem({
    required this.schedule,
    required this.ctrl,
    required this.ob,
  });

  int get _hour => int.tryParse(schedule.time.split(':')[0]) ?? 0;

  String get _periodName {
    if (_hour < 10) return 'Buổi sáng';
    if (_hour < 13) return 'Buổi trưa';
    if (_hour < 17) return 'Buổi chiều';
    if (_hour < 20) return 'Buổi tối';
    return 'Buổi tối muộn';
  }

  IconData get _icon {
    if (_hour < 10) return Icons.wb_sunny_outlined;
    if (_hour < 13) return Icons.wb_sunny_rounded;
    if (_hour < 17) return Icons.cloud_outlined;
    if (_hour < 20) return Icons.nights_stay_outlined;
    return Icons.bedtime_outlined;
  }

  Color get _iconColor {
    if (_hour < 10) return const Color(0xFFFF8C00);
    if (_hour < 13) return const Color(0xFFFFB300);
    if (_hour < 17) return const Color(0xFF42A5F5);
    if (_hour < 20) return const Color(0xFFFF7043);
    return const Color(0xFF5C6BC0);
  }

  @override
  Widget build(BuildContext context) {
    final displayTime = ctrl.formatDisplayTime(schedule.time);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _editTime(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _iconColor.withValues(alpha: 0.15),
              ),
              child: Icon(_icon, size: 20, color: _iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTime,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: schedule.enabled
                          ? ob.textPrimary
                          : ob.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _periodName,
                    style: TextStyle(
                      fontSize: 12,
                      color: ob.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            CustomSwitch(
              value: schedule.enabled,
              onChanged: (v) {
                ctrl.updateSchedule(schedule.copyWith(enabled: v));
              },
              activeColor: ob.switchActive,
              trackColor: ob.switchTrack,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: ob.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTime(BuildContext context) async {
    final parts = schedule.time.split(':');
    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );
    if (picked != null) {
      final time =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await ctrl.updateSchedule(schedule.copyWith(time: time));
    }
  }
}

// ─── Settings Section ─────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  final ReminderController ctrl;
  final OnboardingTheme ob;

  const _SettingsSection({required this.ctrl, required this.ob});

  String get _soundLabel {
    final raw = ctrl.soundEffect.value;
    return raw
        .split('_')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cài đặt nhắc nhở',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: ob.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: ob.bgOption,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ob.borderReminderPill, width: 1),
          ),
          child: Column(
            children: [
              _SettingRow(
                icon: Icons.music_note_outlined,
                iconColor: const Color(0xFF7E57C2),
                title: 'Âm thanh',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _soundLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: ob.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: ob.textSecondary,
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: ob.divider,
                indent: 56,
                endIndent: 0,
              ),
              _SettingRow(
                icon: Icons.vibration_outlined,
                iconColor: const Color(0xFF26A69A),
                title: 'Rung',
                trailing: CustomSwitch(
                  value: ctrl.vibrate.value,
                  onChanged: (v) {
                    ctrl.vibrate.value = v;
                    ctrl.saveSettings();
                  },
                  activeColor: ob.switchActive,
                  trackColor: ob.switchTrack,
                ),
              ),
              Divider(
                height: 1,
                color: ob.divider,
                indent: 56,
                endIndent: 0,
              ),
              _SettingRow(
                icon: Icons.notifications_active_outlined,
                iconColor: const Color(0xFF42A5F5),
                title: 'Thông báo thông minh',
                subtitle: 'Nhắc nhở theo thói quen uống nước của bạn',
                trailing: CustomSwitch(
                  value: ctrl.smartNotification.value,
                  onChanged: (v) {
                    ctrl.smartNotification.value = v;
                    ctrl.saveSettings();
                  },
                  activeColor: ob.switchActive,
                  trackColor: ob.switchTrack,
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}

// ─── Setting Row ──────────────────────────────────────────────────────────────

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget trailing;

  const _SettingRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.15),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ob.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11,
                        color: ob.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
    );
  }
}

// ─── Add Reminder Dialog ──────────────────────────────────────────────────────

Future<void> _showAddDialog(
  BuildContext context,
  ReminderController ctrl,
) async {
  final picked = await showTimePicker(
    context: context,
    initialTime: const TimeOfDay(hour: 9, minute: 0),
  );
  if (picked != null) {
    final time =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    await ctrl.addSchedule(
      ReminderSchedule(
        mode: 'standard',
        time: time,
        label: 'custom',
        enabled: true,
      ),
    );
  }
}
