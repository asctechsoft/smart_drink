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
    final controller = Get.find<TodayController>();
    final unit = Get.find<SettingsController>().volumeUnit.value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final amountLabel = UnitConverter.formatVolumeValueUnit(
          controller.currentAmount.toDouble(),
          unit,
        );
        return _AddDrinkPill(
          imagePath: controller.currentCupImage,
          label: '+$amountLabel',
          drinkName: controller.selectedDrinkType.value.label.tr,
          onTap: () => _addDrink(context),
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
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Chọn kiểu cốc và dung tích phù hợp',
              style: TextStyle(
                fontSize: 13,
                color: ob.textPrimary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              padding: EdgeInsets.zero,
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.95,
              children: List.generate(TodayController.amountPresets.length, (i) {
                return _CupCard(
                  image: TodayController.cupImages[i],
                  volume: UnitConverter.formatVolumeValueUnit(
                    TodayController.amountPresets[i].toDouble(),
                    unit,
                  ),
                  isSelected: tempIndex == i,
                  onTap: () => setS(() => tempIndex = i),
                );
              }),
            ),
          ],
        );
      },
    ),
  );
}

/// Opens the drink-type picker (searchable grid with hydration %) and stores
/// the choice on [TodayController].
void showDrinkTypeSheet(BuildContext context) {
  final controller = Get.find<TodayController>();
  PrimaryBottomSheet.show(
    context: context,
    title: 'Loại đồ uống',
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
  final String imagePath;
  final String label;
  final String drinkName;
  final VoidCallback onTap;

  const _AddDrinkPill({
    required this.imagePath,
    required this.label,
    required this.drinkName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 56,
        width: Get.width * 0.8,
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
            Image.asset(imagePath, width: 30, height: 30, fit: BoxFit.contain),
            const SizedBox(width: 12),
            Container(
              width: 1,
              height: 24,
              color: AppColors.basic500.withValues(alpha: 0.35),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: AppTextAutoResize(
                '$label  -  $drinkName',
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

// ─── Cup type card ────────────────────────────────────────────────────────────

class _CupCard extends StatelessWidget {
  final String image;
  final String volume;
  final bool isSelected;
  final VoidCallback onTap;

  const _CupCard({
    required this.image,
    required this.volume,
    required this.isSelected,
    required this.onTap,
  });

  static const _cyan = Color(0xFF4FC3F7);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? _cyan.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? _cyan
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: _cyan.withValues(alpha: 0.35), blurRadius: 12)]
              : null,
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Row(
              children: [
                Image.asset(
                  image,
                  width: 46,
                  height: 46,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    volume,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _cyan,
                    ),
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.check_circle_rounded, size: 20, color: _cyan),
              ),
          ],
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
      children: [
        Text(
          'Chọn loại đồ uống và xem % nước đóng góp',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: ob.textPrimary.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: GridView.count(
            padding: EdgeInsets.zero,
            crossAxisCount: 2,
            shrinkWrap: true,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.0,
            children: DrinkType.values.map((type) {
              return _DrinkCard(
                type: type,
                isSelected: selected == type,
                onTap: () => onSelected(type),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DrinkCard extends StatelessWidget {
  final DrinkType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrinkCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  static const _cyan = Color(0xFF4FC3F7);

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? _cyan.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _cyan : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: _cyan.withValues(alpha: 0.3), blurRadius: 10)]
              : null,
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Row(
              children: [
                Image.asset(
                  type.imagePath,
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        type.viName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                          color: ob.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: _cyan.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          '${type.waterPercent}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _cyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
            if (isSelected)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.check_circle_rounded, size: 20, color: _cyan),
              ),
          ],
        ),
      ),
    );
  }
}
