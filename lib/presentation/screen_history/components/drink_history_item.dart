import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/models/data_models/drink_record.dart';
import 'package:smartdrinkai/models/ui_models/drink_type.dart';
import 'package:smartdrinkai/utils/unit_converter.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';
import 'package:smartdrinkai/values/app_colors.dart';

class DrinkHistoryItem extends StatelessWidget {
  final DrinkRecord record;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DrinkHistoryItem({
    super.key,
    required this.record,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final type = DrinkType.values.firstWhere(
      (t) => t.name == record.drinkType,
      orElse: () => DrinkType.water,
    );
    final timeFormat = Get.find<SettingsController>().timeFormat.value;
    final timeStr = UnitConverter.formatTime(
      '${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')}',
      timeFormat,
    );
    final volumeUnit = Get.find<SettingsController>().volumeUnit.value;
    final double displayMl = record.originalAmountMl > 0
        ? record.originalAmountMl
        : record.amountMl.toDouble();
    final amountDisplay = UnitConverter.formatVolumeValueUnit(
      displayMl,
      volumeUnit,
    );

    final ob = OnboardingTheme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(12, 16, 12, 16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: ob.bgOption,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AppRow(
        children: [
          // Time
          AppText(
            timeStr,
            modifier: Modifier.background(
              color: ob.bgTimeCycle,
              radius: 100,
            ).padding(horizontal: 8, vertical: 8),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w400,
              color: ob.textPrimary,
              letterSpacing: 0.6,
            ),
          ),
          AppSpacerW8,
          // Drink icon
          Image.asset(
            type.imagePath,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
          AppSpacerW4,
          // Drink name
          Expanded(
            child: AppText(
              type.label.tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ob.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Amount (show original drink amount)
          AppRow(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppRow(
                modifier: Modifier.appClickable(
                  onTap: onEdit,
                  radius: 16,
                ).padding(vertical: 4, horizontal: 2),
                children: [
                  AppText(
                    amountDisplay,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ob.textActiveBottomNavBar,
                      letterSpacing: 0.5,
                    ),
                  ),
                  AppSpacerW4,

                  // Edit icon
                  AppIcon(
                    'assets/images/svg/ic_edit_water.svg',
                    size: 16,
                    tint: ob.textActiveBottomNavBar,
                  ),
                ],
              ),
              // Delete icon
              AppIcon(
                'assets/images/svg/ic_remove.svg',
                size: 16,
                clickZone: 32,
                tint: AppColors.danger500,
                onClick: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

