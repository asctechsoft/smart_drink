import 'package:dsp_base/app_material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternudge/controller/reminder_controller.dart';
import 'package:waternudge/models/ui_models/reminder_mode.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';
import 'package:waternudge/values/onboarding_theme.dart';

import 'components/interval_mode_content.dart';
import 'components/standard_mode_content.dart';
import 'components/reminder_slots_section.dart';

class ReminderSettingsPage extends StatelessWidget {
  const ReminderSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ReminderController>();

    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            children: [
              const _HeaderBanner(),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ModeTabs(ctrl: ctrl),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() {
                  switch (ctrl.mode.value) {
                    case ReminderMode.interval:
                      return IntervalModeContent(controller: ctrl);
                    case ReminderMode.custom:
                      return DisabledOverlay(
                        disabled: !ctrl.enabled.value,
                        child: ReminderSlotsSection(controller: ctrl),
                      );
                    case ReminderMode.standard:
                      return StandardModeContent(controller: ctrl);
                  }
                }),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header banner ────────────────────────────────────────────────────────────

class _HeaderBanner extends StatelessWidget {
  const _HeaderBanner();

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nhắc nhở',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: ob.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thiết lập nhắc uống nước mỗi ngày',
                  style: TextStyle(fontSize: 13, color: ob.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Image.asset(
            'assets/images/webp/img_bg_noti.webp',
            height: 88,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

// ─── Standard / Interval mode tabs ──────────────────────────────────────────────

class _ModeTabs extends StatelessWidget {
  final ReminderController ctrl;
  const _ModeTabs({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mode = ctrl.mode.value;
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            _ModeTab(
              icon: Icons.access_time_rounded,
              label: 'Standard',
              selected: mode == ReminderMode.standard,
              onTap: () => ctrl.setMode(ReminderMode.standard),
            ),
            _ModeTab(
              icon: Icons.timer_outlined,
              label: 'Interval',
              selected: mode == ReminderMode.interval,
              onTap: () => ctrl.setMode(ReminderMode.interval),
            ),
            _ModeTab(
              icon: Icons.edit_calendar_outlined,
              label: 'Custom',
              selected: mode == ReminderMode.custom,
              onTap: () => ctrl.setMode(ReminderMode.custom),
            ),
          ],
        ),
      );
    });
  }
}

class _ModeTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF1575CE), Color(0xFF0B58D6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF1575CE).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
