import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/onboarding_controller.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/presentation/common_components/primary_bottom_sheet.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:smartdrinkai/utils/toast_utils.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class IntervalPickerSheet extends StatefulWidget {
  final OnboardingController controller;

  const IntervalPickerSheet({super.key, required this.controller});

  static void show(BuildContext context, OnboardingController controller) {
    PrimaryBottomSheet.show(
      context: context,
      title: 'interval'.tr,
      showSubmitButton: false,
      content: IntervalPickerSheet(controller: controller),
    );
  }

  @override
  State<IntervalPickerSheet> createState() => _IntervalPickerSheetState();
}

class _IntervalPickerSheetState extends State<IntervalPickerSheet> {
  late int hours;
  late int minutes;
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;

  @override
  void initState() {
    super.initState();
    hours = widget.controller.intervalMinutes.value ~/ 60;
    minutes = widget.controller.intervalMinutes.value % 60;
    hourController = FixedExtentScrollController(initialItem: hours);
    minuteController = FixedExtentScrollController(initialItem: minutes);
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);

    return AppColumn(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: ob.isLight
                            ? ob.textPrimary.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
        const AppSpacerH(24),
        PrimaryButton(
          text: 'save'.tr,
          width: double.infinity,
          useGradient: true,
          onPressed: () {
            if (hours == 0 && minutes < 5) {
              ToastUtils.showToast(context, 'interval_min_5'.tr);
              return;
            }
            widget.controller.intervalMinutes.value = hours * 60 + minutes;
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

