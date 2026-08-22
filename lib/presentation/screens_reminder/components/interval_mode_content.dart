import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/reminder_controller.dart';
import 'package:smartdrinkai/presentation/common_components/primary_bottom_sheet.dart';
import 'package:smartdrinkai/utils/toast_utils.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
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
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Interval header row ──
            Row(
              children: [
                _iconCircle(Icons.timer_outlined),
                const SizedBox(width: 12),
                Text(
                  'Khoảng thời gian',
                  style: TextStyle(
                    color: ob.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showIntervalPicker(context, controller),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                      const Icon(Icons.edit_outlined, size: 16, color: _cyan),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
            const SizedBox(height: 16),

            // ── Quick interval chips ──
            Text(
              'Chọn nhanh khoảng thời gian',
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
                    if (i < _quickMinutes.length - 1) const SizedBox(width: 12),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Sleep window ──
            Text(
              'Khoảng thời gian ngủ',
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
                    label: 'Giờ đi ngủ',
                    time: controller.formatDisplayTime(
                      controller.sleepTimeStart.value,
                    ),
                    onTap: () => showWheelTimePicker(
                      context,
                      title: 'sleep_time_start'.tr,
                      initialTime: controller.sleepTimeStart.value,
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
                    label: 'Giờ thức dậy',
                    time: controller.formatDisplayTime(
                      controller.sleepTimeEnd.value,
                    ),
                    onTap: () => showWheelTimePicker(
                      context,
                      title: 'sleep_time_end'.tr,
                      initialTime: controller.sleepTimeEnd.value,
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
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
                      'Chúng tôi sẽ nhắc bạn mỗi ${controller.intervalDisplay} '
                      'trong khoảng thời gian bạn thức dậy, không nhắc trong '
                      'giờ ngủ đã thiết lập.',
                      style: TextStyle(
                        color: ob.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Image.asset(
                    'assets/images/webp/img_cup_water.webp',
                    width: 44,
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _iconCircle(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _cyan.withValues(alpha: 0.12),
        border: Border.all(color: _cyan.withValues(alpha: 0.35)),
      ),
      child: Icon(icon, size: 22, color: _cyan),
    );
  }

  Widget _quickChip(OnboardingTheme ob, int minutes, bool selected, Key key) {
    return GestureDetector(
      key: key,
      onTap: () => _selectMinutes(minutes),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? _cyan.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? _cyan : Colors.white.withValues(alpha: 0.1),
            width: selected ? 1.4 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: _cyan.withValues(alpha: 0.3), blurRadius: 8)]
              : null,
        ),
        child: Text(
          '$minutes phút',
          maxLines: 1,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? _cyan : ob.textPrimary.withValues(alpha: 0.85),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: ob.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
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
                ],
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
      ),
    );
  }
}

void _showIntervalPicker(BuildContext context, ReminderController controller) {
  int hours = controller.intervalMinutes.value ~/ 60;
  int minutes = controller.intervalMinutes.value % 60;

  final hourController = FixedExtentScrollController(initialItem: hours);
  final minuteController = FixedExtentScrollController(initialItem: minutes);
  final ob = OnboardingTheme.of(context);
  PrimaryBottomSheet.show(
    context: context,
    title: 'set_interval'.tr,
    buttonText: 'save'.tr,
    onButtonPressed: () {
      if (hours == 0 && minutes < 5) {
        ToastUtils.showToast(context, 'interval_min_5'.tr);
        return;
      }
      controller.intervalMinutes.value = hours * 60 + minutes;
      controller.saveSettings();
      Navigator.pop(context);
    },
    content: StatefulBuilder(
      builder: (ctx, setState) => Stack(
        alignment: Alignment.center,
        children: [
          // Positioned(
          //   left: 0,
          //   right: 0,
          //   child: IgnorePointer(
          //     child: Container(
          //       height: 60,
          //       decoration: BoxDecoration(
          //         border: Border.symmetric(
          //           horizontal: BorderSide(
          //             color: const Color.fromARGB(
          //               255,
          //               44,
          //               27,
          //               27,
          //             ).withValues(alpha: 0.1),
          //             width: 1,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          AppRow(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hours Wheel
              SizedBox(
                width: 130,
                height: 300,
                child: ListWheelScrollView.useDelegate(
                  controller: hourController,
                  itemExtent: 60,
                  physics: const FixedExtentScrollPhysics(),
                  overAndUnderCenterOpacity: 1.0,
                  onSelectedItemChanged: (i) {
                    setState(() => hours = i);
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      if (index < 0 || index > 12) return null;
                      final isSelected = index == hours;
                      final distance = (index - hours).abs();
                      Color itemColor = ob.textPrimary;
                      if (distance == 1) {
                        itemColor = ob.textPrimary.withValues(alpha: 0.5);
                      } else if (distance >= 2) {
                        itemColor = ob.textPrimary.withValues(alpha: 0.1);
                      }

                      String label =
                          '$index ${index <= 1 ? 'hour'.tr : 'hours'.tr}';

                      return Center(
                        child: AppText(
                          label,
                          style: TextStyle(
                            fontSize: isSelected ? 32 : 18,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: itemColor,
                          ),
                        ),
                      );
                    },
                    childCount: 13,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppText(
                  ':',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: ob.textPrimary,
                  ),
                ),
              ),
              // Minutes Wheel
              SizedBox(
                width: 130,
                height: 300,
                child: ListWheelScrollView.useDelegate(
                  controller: minuteController,
                  itemExtent: 60,
                  physics: const FixedExtentScrollPhysics(),
                  overAndUnderCenterOpacity: 1.0,
                  onSelectedItemChanged: (i) {
                    int normalized = i % 60;
                    if (normalized < 0) normalized += 60;
                    setState(() => minutes = normalized);
                  },
                  childDelegate: ListWheelChildLoopingListDelegate(
                    children: List.generate(60, (index) {
                      int distance = (index - minutes).abs();
                      if (distance > 30) distance = 60 - distance;

                      final isSelected = distance == 0;
                      Color itemColor = ob.textPrimary;
                      if (distance == 1) {
                        itemColor = ob.textPrimary.withValues(alpha: 0.5);
                      } else if (distance >= 2) {
                        itemColor = ob.textPrimary.withValues(alpha: 0.1);
                      }

                      String label =
                          '${index.toString().padLeft(2, '0')} ${'min'.tr}';

                      return Center(
                        child: AppText(
                          label,
                          style: TextStyle(
                            fontSize: isSelected ? 32 : 18,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: itemColor,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
