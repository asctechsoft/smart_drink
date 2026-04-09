import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/reminder_controller.dart';
import 'package:smartdrinkai/presentation/common_components/primary_bottom_sheet.dart';
import 'package:smartdrinkai/utils/toast_utils.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';

import 'standard_mode_content.dart';

class IntervalModeContent extends StatelessWidget {
  final ReminderController controller;
  const IntervalModeContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Obx(() {
      return AppColumn(
        modifier: Modifier.background(
          color: ob.bgReminderOption,
          radius: 16,
        ).padding(all: 12),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Interval row
          AppRow(
            modifier: Modifier.appClickable(
              onTap: () {
                _showIntervalPicker(context, controller);
              },
              radius: 16,
            ).padding(vertical: 16).paddingLR(left: 12),
            children: [
              Expanded(
                child: AppText(
                  'interval'.tr,
                  style: TextStyle(
                    color: ob.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              AppText(
                controller.intervalDisplay,
                style: TextStyle(
                  color: ob.textActiveBottomNavBar,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const AppSpacerW(4),
              AppIcon(
                'assets/images/svg/ic_edit.svg',
                size: 16,
                tint: ob.textActiveBottomNavBar,
              ),
            ],
          ),
          // Bedtime row
          AppRow(
            modifier: Modifier.padding(vertical: 16).paddingLR(left: 12),
            children: [
              AppText(
                'bedtime'.tr,
                style: TextStyle(
                  color: ob.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // Sleep start
              InkWell(
                borderRadius: BorderRadius.circular(12),
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
                child: AppRow(
                  modifier: Modifier.paddingAll(2),
                  children: [
                    AppText(
                      controller.formatDisplayTime(
                        controller.sleepTimeStart.value,
                      ),
                      style: TextStyle(
                        color: ob.textActiveBottomNavBar,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const AppSpacerW(4),
                    AppIcon(
                      'assets/images/svg/ic_edit.svg',
                      size: 16,
                      tint: ob.textActiveBottomNavBar,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AppText(
                  'to'.tr,
                  style: TextStyle(
                    color: ob.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Sleep end
              InkWell(
                borderRadius: BorderRadius.circular(12),
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
                child: AppRow(
                  modifier: Modifier.paddingAll(2),
                  children: [
                    AppText(
                      controller.formatDisplayTime(
                        controller.sleepTimeEnd.value,
                      ),
                      style: TextStyle(
                        color: ob.textActiveBottomNavBar,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const AppSpacerW(4),
                    AppIcon(
                      'assets/images/svg/ic_edit.svg',
                      size: 16,
                      tint: ob.textActiveBottomNavBar,
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppText(
            "we_ll_remind_you_every".trParams({
              "args1": controller.intervalDisplay,
            }),
            style: TextStyle(
              color: ob.textSubtitle,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    });
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

