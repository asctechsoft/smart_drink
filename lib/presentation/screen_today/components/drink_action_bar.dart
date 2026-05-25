import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/controller/today_controller.dart';
import 'package:smartdrinkai/models/ui_models/drink_type.dart';
import 'package:smartdrinkai/presentation/common_components/primary_bottom_sheet.dart';
import 'package:smartdrinkai/utils/toast_utils.dart';
import 'package:smartdrinkai/utils/unit_converter.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';

class DrinkActionBar extends StatefulWidget {
  const DrinkActionBar({super.key});

  @override
  State<DrinkActionBar> createState() => _DrinkActionBarState();
}

class _DrinkActionBarState extends State<DrinkActionBar> {
  static const _presets = [150, 200, 300, 500, 700];
  static const _presetIcons = [
    'assets/images/svg/ic_water_capacity_150.svg',
    'assets/images/svg/ic_water_capacity_200.svg',
    'assets/images/svg/ic_water_capacity_300.svg',
    'assets/images/svg/ic_water_capacity_500.svg',
    'assets/images/svg/ic_water_capacity_700.svg',
  ];

  int _amountIndex = 1; // default 200ml
  DrinkType _drinkType = DrinkType.water;

  Future<void> _addDrink() async {
    final controller = Get.find<TodayController>();
    final amount = _presets[_amountIndex];
    final effectiveWater = (amount * _drinkType.waterPercent / 100).round();
    if (controller.currentIntakeMl.value + effectiveWater > 8000) {
      ToastUtils.showLimitToast(context);
      return;
    }
    await controller.addDrink(
      effectiveWater,
      originalAmountMl: amount.toDouble(),
      drinkType: _drinkType.name,
    );
  }

  void _showCupSizeSheet() {
    int tempIndex = _amountIndex;
    PrimaryBottomSheet.show(
      context: context,
      title: 'Loại cốc'.tr,
      buttonText: 'save'.tr,
      onButtonPressed: () {
        setState(() => _amountIndex = tempIndex);
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
              children: List.generate(_presets.length, (i) {
                final isSelected = tempIndex == i;
                return _VolumeButton(
                  label: UnitConverter.formatVolumeValueUnit(
                    _presets[i].toDouble(),
                    unit,
                  ),
                  icon: _presetIcons[i],
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

  void _showDrinkTypeSheet() {
    PrimaryBottomSheet.show(
      context: context,
      title: 'drink_type'.tr,
      showSubmitButton: false,
      content: _DrinkTypePicker(
        selected: _drinkType,
        onSelected: (type) {
          setState(() => _drinkType = type);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final unit = Get.find<SettingsController>().volumeUnit.value;
    final amount = _presets[_amountIndex];
    final amountLabel = UnitConverter.formatVolumeValueUnit(
      amount.toDouble(),
      unit,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Left: cup size
          _SideButton(
            icon: _presetIcons[_amountIndex],
            label: 'Loại cốc'.tr,
            onTap: _showCupSizeSheet,
          ),
          const SizedBox(width: 16),
          // Middle: add drink control
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CircleBtn(
                      icon: Icons.remove_rounded,
                      enabled: _amountIndex > 0,
                      onTap: () => setState(() => _amountIndex--),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _addDrink,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ob.accent,
                              ob.accent.withValues(alpha: 0.75),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: ob.accent.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppIcon(_presetIcons[_amountIndex], size: 20),
                            const SizedBox(width: 6),
                            Text(
                              '+$amountLabel',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _CircleBtn(
                      icon: Icons.add_rounded,
                      enabled: _amountIndex < _presets.length - 1,
                      onTap: () => setState(() => _amountIndex++),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _drinkType.label.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: ob.textSecondary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right: drink type
          _SideButton(
            imagePath: _drinkType.imagePath,
            label: 'menu'.tr,
            onTap: _showDrinkTypeSheet,
          ),
        ],
      ),
    );
  }
}

// ─── Side button (left/right) ────────────────────────────────────────────────

class _SideButton extends StatelessWidget {
  final String? icon;
  final String? imagePath;
  final String label;
  final VoidCallback onTap;

  const _SideButton({
    this.icon,
    this.imagePath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: ob.bgOption,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ob.borderTabHistory, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath!,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              )
            else if (icon != null)
              AppIcon(icon!, size: 24, tint: ob.iconPill),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: ob.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Circle ±  button ────────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _CircleBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ob.bgOption,
          border: Border.all(color: ob.borderTabHistory, width: 1),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled
              ? ob.textPrimary
              : ob.textSecondary.withValues(alpha: 0.35),
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
