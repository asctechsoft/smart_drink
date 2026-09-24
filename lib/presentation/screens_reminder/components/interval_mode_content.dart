import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waternudge/controller/reminder_controller.dart';
import 'package:waternudge/presentation/common_components/wheel_duration_picker.dart';
import 'package:waternudge/utils/toast_utils.dart';
import 'package:waternudge/values/onboarding_theme.dart';
import 'package:get/get.dart';

import 'standard_mode_content.dart';

class IntervalModeContent extends StatefulWidget {
  final ReminderController controller;
  const IntervalModeContent({super.key, required this.controller});

  @override
  State<IntervalModeContent> createState() => _IntervalModeContentState();
}

class _IntervalModeContentState extends State<IntervalModeContent> {
  ReminderController get controller => widget.controller;

  static const _quickMinutes = [30, 45, 60, 90, 120];
  static const _cyan = Color(0xFF4FC3F7);

  // Shared ink colours for every tappable surface on this tab.
  static const _rowRadius = BorderRadius.all(Radius.circular(12));
  static final Color _splash = _cyan.withValues(alpha: 0.18);
  static final Color _highlight = Colors.white.withValues(alpha: 0.06);

  final ScrollController _chipScroll = ScrollController();
  final List<GlobalKey> _chipKeys = List.generate(5, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void dispose() {
    _chipScroll.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    final i = _quickMinutes.indexOf(controller.intervalMinutes.value);
    if (i < 0) return;
    final ctx = _chipKeys[i].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _selectMinutes(int minutes) {
    controller.intervalMinutes.value = minutes;
    controller.saveSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Obx(() {
      return DisabledOverlay(
        disabled: !controller.enabled.value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Interval header row ──
              // The whole row opens the duration picker, not just the value and
              // its pencil — the label and icon read as part of the same button.
              Material(
                color: Colors.transparent,
                borderRadius: _rowRadius,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => showWheelDurationPicker(
                    context,
                    title: 'interval_title'.tr,
                    initialMinutes: controller.intervalMinutes.value,
                    onSave: (minutes) {
                      controller.intervalMinutes.value = minutes;
                      controller.saveSettings();
                    },
                  ),
                  borderRadius: _rowRadius,
                  splashColor: _splash,
                  highlightColor: _highlight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        _iconCircle(Icons.timer_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Full width on its own line — sharing the row
                              // with the value used to ellipsize this title.
                              Text(
                                'interval_title'.tr,
                                style: TextStyle(
                                  color: ob.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    controller.intervalDisplay,
                                    style: const TextStyle(
                                      color: _cyan,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                    color: _cyan,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
              const SizedBox(height: 10),

              // ── Quick interval chips ──
              Text(
                'interval_quick_pick'.tr,
                style: TextStyle(color: ob.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                controller: _chipScroll,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Row(
                  children: [
                    for (var i = 0; i < _quickMinutes.length; i++) ...[
                      _quickChip(
                        ob,
                        _quickMinutes[i],
                        controller.intervalMinutes.value == _quickMinutes[i],
                        _chipKeys[i],
                      ),
                      if (i < _quickMinutes.length - 1)
                        const SizedBox(width: 12),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ── Sleep window ──
              Text(
                'interval_sleep_window'.tr,
                style: TextStyle(color: ob.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _sleepCard(
                      ob,
                      icon: Icons.nightlight_round,
                      iconColor: const Color(0xFF7C83FF),
                      label: 'interval_bedtime_label'.tr,
                      time: controller.formatDisplayTime(
                        controller.sleepTimeStart.value,
                      ),
                      onTap: () => showWheelTimePicker(
                        context,
                        title: 'sleep_time_start'.tr,
                        initialTime: controller.sleepTimeStart.value,
                        enhanced: true,
                        subtitle: 'picker_device_format_hint',
                        infoText: 'reminder_pause_info',
                        onSave: (t) {
                          if (t == controller.sleepTimeEnd.value) {
                            ToastUtils.showToast(
                              context,
                              'sleep_start_end_cannot_be_same'.tr,
                            );
                            return;
                          }
                          controller.sleepTimeStart.value = t;
                          controller.saveSettings();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _sleepCard(
                      ob,
                      icon: Icons.wb_sunny_rounded,
                      iconColor: const Color(0xFFFFC107),
                      label: 'interval_wakeup_label'.tr,
                      time: controller.formatDisplayTime(
                        controller.sleepTimeEnd.value,
                      ),
                      onTap: () => showWheelTimePicker(
                        context,
                        title: 'sleep_time_end'.tr,
                        initialTime: controller.sleepTimeEnd.value,
                        enhanced: true,
                        subtitle: 'picker_device_format_hint',
                        infoText: 'reminder_pause_info',
                        onSave: (t) {
                          if (t == controller.sleepTimeStart.value) {
                            ToastUtils.showToast(
                              context,
                              'sleep_start_end_cannot_be_same'.tr,
                            );
                            return;
                          }
                          controller.sleepTimeEnd.value = t;
                          controller.saveSettings();
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Info card ──
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 22,
                      color: _cyan,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'interval_info'.trParams({
                          'args1': controller.intervalDisplay,
                        }),
                        style: TextStyle(
                          color: ob.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SvgPicture.asset(
                      'assets/images/svg/ic_cup_water_bar.svg',
                      width: 44,
                      height: 44,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Unified icon box — matches the Settings screen (42×42 rounded square,
  // mint icon, subtle white border).
  Widget _iconCircle(IconData icon) {
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
      child: Center(
        child: Icon(icon, size: 24, color: const Color(0xFF96D2A8)),
      ),
    );
  }

  Widget _quickChip(OnboardingTheme ob, int minutes, bool selected, Key key) {
    const radius = BorderRadius.all(Radius.circular(100));
    return DecoratedBox(
      key: key,
      decoration: BoxDecoration(
        color: selected
            ? _cyan.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: radius,
        border: Border.all(
          color: selected ? _cyan : Colors.white.withValues(alpha: 0.1),
          width: selected ? 1.4 : 1,
        ),
        boxShadow: selected
            ? [BoxShadow(color: _cyan.withValues(alpha: 0.3), blurRadius: 8)]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _selectMinutes(minutes),
          borderRadius: radius,
          splashColor: _splash,
          highlightColor: _highlight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            alignment: Alignment.center,
            child: Text(
              '$minutes ${'unit_minutes'.tr}',
              maxLines: 1,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected
                    ? _cyan
                    : ob.textPrimary.withValues(alpha: 0.85),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sleepCard(
    OnboardingTheme ob, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String time,
    required VoidCallback onTap,
  }) {
    const radius = BorderRadius.all(Radius.circular(14));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: radius,
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: _splash,
          highlightColor: _highlight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // The label gets the card's full width on its own line — with
                // the icon on this row too it was cramped enough to ellipsize
                // ("Giờ thức ...").
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: ob.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(icon, size: 30, color: iconColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          time,
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                            color: _cyan,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: ob.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
