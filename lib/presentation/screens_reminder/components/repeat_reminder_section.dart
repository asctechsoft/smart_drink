import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/reminder_controller.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';

class RepeatReminderSection extends StatefulWidget {
  final ReminderController controller;
  const RepeatReminderSection({super.key, required this.controller});

  @override
  State<RepeatReminderSection> createState() => _RepeatReminderSectionState();
}

class _RepeatReminderSectionState extends State<RepeatReminderSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return AppColumn(
      children: [
        AppRow(
          modifier: Modifier.appClickable(
            onTap: () => setState(() => _expanded = !_expanded),
            radius: 16,
          ).padding(all: 12),
          children: [
            Expanded(
              child: AppColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'repeat_reminder'.tr,
                    style: TextStyle(
                      color: ob.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const AppSpacerH(2),
                  Obx(
                    () => AppText(
                      widget.controller.getRepeatDaysSummary(),
                      style: TextStyle(
                        color: ob.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppIcon(
              _expanded
                  ? 'assets/images/svg/ic_arrow_up.svg'
                  : 'assets/images/svg/ic_arrow_down.svg',
              tint: ob.textPrimary,
            ),
          ],
        ),
        if (_expanded)
          Obx(() {
            const dayNames = [
              'monday',
              'tuesday',
              'wednesday',
              'thursday',
              'friday',
              'saturday',
              'sunday',
            ];
            return AppColumn(
              modifier: Modifier.background(
                color: ob.bgReminderOption,
                radius: 16,
              ).padding(vertical: 8),
              children: List.generate(7, (i) {
                final day = i + 1;
                final isSelected = widget.controller.repeatDays.contains(day);
                return AppRow(
                  modifier: Modifier.appClickable(
                    onTap: () => widget.controller.toggleDay(day),
                    radius: 16,
                  ).paddingLR(left: 24, right: 12).padding(vertical: 16),
                  children: [
                    Expanded(
                      child: AppText(
                        dayNames[i].tr,
                        style: TextStyle(
                          color: ob.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _buildCheckbox(isSelected),
                  ],
                );
              }),
            );
          }),
      ],
    );
  }

  Widget _buildCheckbox(bool checked) {
    final ob = OnboardingTheme.of(context);
    return AppBoxCentered(
      modifier: Modifier.width(
        20,
      ).height(20).border(width: 1.5, color: ob.switchActive, radius: 6),
      children: [
        if (checked)
          AppIcon(
            'assets/images/svg/ic_check.svg',
            size: 14,
            tint: ob.switchActive,
          ),
      ],
    );
  }
}

