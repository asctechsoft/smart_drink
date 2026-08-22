import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/controller/today_controller.dart';
import 'package:smartdrinkai/models/ui_models/drink_type.dart';
import 'package:smartdrinkai/presentation/common_components/primary_bottom_sheet.dart';
import 'package:smartdrinkai/utils/toast_utils.dart';
import 'package:smartdrinkai/utils/unit_converter.dart';
import 'package:smartdrinkai/values/app_colors.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';

class DrinkActionBar extends StatelessWidget {
  const DrinkActionBar({super.key});

  Future<void> _addDrink(BuildContext context) async {
    final controller = Get.find<TodayController>();
    final amount = controller.currentAmount;
    final drinkType = controller.selectedDrinkType.value;
    final effectiveWater = (amount * drinkType.waterPercent / 100).round();
    if (controller.currentIntakeMl.value + effectiveWater > 8000) {
      ToastUtils.showLimitToast(context);
      return;
    }
    await controller.addDrink(
      effectiveWater,
      originalAmountMl: amount.toDouble(),
      drinkType: drinkType.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final controller = Get.find<TodayController>();
    final unit = Get.find<SettingsController>().volumeUnit.value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final amountLabel = UnitConverter.formatVolumeValueUnit(
          controller.currentAmount.toDouble(),
          unit,
        );
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _AddDrinkPill(
              icon: controller.currentAmountIcon,
              label: '+$amountLabel',
              onTap: () => _addDrink(context),
            ),
            const SizedBox(height: 6),
            Text(
              controller.selectedDrinkType.value.label.tr,
              style: TextStyle(
                fontSize: 14,
                color: ob.textSecondary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ─── Cup size / drink type sheets (shared with the stat row) ──────────────────

/// Opens the cup-size picker and stores the choice on [TodayController].
void showCupSizeSheet(BuildContext context) {
  final controller = Get.find<TodayController>();
  int tempIndex = controller.selectedAmountIndex.value;
  PrimaryBottomSheet.show(
    context: context,
    title: 'Loại cốc'.tr,
    buttonText: 'save'.tr,
    onButtonPressed: () {
      controller.selectedAmountIndex.value = tempIndex;
      Navigator.pop(context);
    },
    content: StatefulBuilder(
      builder: (ctx, setS) {
        final ob = OnboardingTheme.of(ctx);
        final unit = Get.find<SettingsController>().volumeUnit.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: ob.bgOption,
            border: Border.all(color: ob.borderReminderPill, width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            padding: EdgeInsets.zero,
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: List.generate(TodayController.amountPresets.length, (i) {
              final isSelected = tempIndex == i;
              return _VolumeButton(
                label: UnitConverter.formatVolumeValueUnit(
                  TodayController.amountPresets[i].toDouble(),
                  unit,
                ),
                icon: TodayController.amountPresetIcons[i],
                isSelected: isSelected,
                onTap: () => setS(() => tempIndex = i),
              );
            }),
          ),
        );
      },
    ),
  );
}

/// Opens the drink-type picker and stores the choice on [TodayController].
void showDrinkTypeSheet(BuildContext context) {
  final controller = Get.find<TodayController>();
  PrimaryBottomSheet.show(
    context: context,
    title: 'drink_type'.tr,
    showSubmitButton: false,
    content: _DrinkTypePicker(
      selected: controller.selectedDrinkType.value,
      onSelected: (type) {
        controller.selectedDrinkType.value = type;
        Navigator.pop(context);
      },
    ),
  );
}

// ─── Add drink pill (centre) ─────────────────────────────────────────────────

class _AddDrinkPill extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _AddDrinkPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: AppColors.gradientAccentPill,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardGlow.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(icon, size: 26),
            const SizedBox(width: 12),
            Container(
              width: 1,
              height: 24,
              color: AppColors.basic500.withValues(alpha: 0.35),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: AppTextAutoResize(
                label,
                maxLines: 1,
                minFontSize: 12,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.basic500,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Cup size grid button ─────────────────────────────────────────────────────

class _VolumeButton extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _VolumeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? ob.accent.withValues(alpha: 0.15)
                : ob.bgDrinkItem,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? ob.accent : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(
                icon,
                size: 24,
                tint: isSelected ? ob.accent : ob.iconAmountWater,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? ob.accent : ob.iconAmountWater,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Drink type picker ────────────────────────────────────────────────────────

class _DrinkTypePicker extends StatelessWidget {
  final DrinkType selected;
  final ValueChanged<DrinkType> onSelected;

  const _DrinkTypePicker({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: DrinkType.values.map((type) {
        final isSelected = selected == type;
        return GestureDetector(
          onTap: () => onSelected(type),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? ob.accent.withValues(alpha: 0.12)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected ? ob.accent : ob.bgOptionSelected,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Image.asset(
                  type.imagePath,
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    type.label.tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? ob.accent : ob.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: ob.accent, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
