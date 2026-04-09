import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/models/ui_models/drink_type.dart';
import 'package:smartdrinkai/presentation/common_components/primary_bottom_sheet.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/presentation/common_components/primary_dialog.dart';
import 'package:smartdrinkai/utils/unit_converter.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DrinkSelectionBottomSheet extends StatefulWidget {
  final DrinkType drinkType;
  final ValueChanged<double> onDrink;

  const DrinkSelectionBottomSheet({
    super.key,
    required this.drinkType,
    required this.onDrink,
  });

  static void show({
    required BuildContext context,
    required DrinkType drinkType,
    required ValueChanged<double> onDrink,
  }) {
    PrimaryBottomSheet.show(
      context: context,
      title: drinkType.label,
      showSubmitButton: false, // Chúng ta dùng nút tùy chỉnh bên dưới
      content: DrinkSelectionBottomSheet(
        drinkType: drinkType,
        onDrink: onDrink,
      ),
    );
  }

  @override
  State<DrinkSelectionBottomSheet> createState() =>
      _DrinkSelectionBottomSheetState();
}

class _DrinkSelectionBottomSheetState extends State<DrinkSelectionBottomSheet> {
  late int _selectedAmount;
  bool _isCustom = false;

  final List<int> _presetAmounts = [150, 200, 300, 500, 700];
  final List<String> _presetIcons = [
    'assets/images/svg/ic_water_capacity_150.svg',
    'assets/images/svg/ic_water_capacity_200.svg',
    'assets/images/svg/ic_water_capacity_300.svg',
    'assets/images/svg/ic_water_capacity_500.svg',
    'assets/images/svg/ic_water_capacity_700.svg',
  ];

  @override
  void initState() {
    super.initState();
    _selectedAmount = 150;
  }

  void _showCustomDialog() async {
    final controller = TextEditingController();
    final unit = Get.find<SettingsController>().volumeUnit.value;
    final result = await PrimaryDialog.show<double>(
      context: context,
      title: 'custom_drink'.tr,
      content: StatefulBuilder(
        builder: (ctx, setState) {
          final ob = OnboardingTheme.of(ctx);
          return AppColumn(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppRow(
                modifier: Modifier.background(
                  color: ob.bgToggle,
                  radius: 12,
                ).padding(horizontal: 16),
                children: [
                  AppIcon(
                    'assets/images/webp/img_measuring_cup.webp',
                    size: 24,
                    tint: ob.switchActive,
                  ),
                  const AppSpacerW(8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      keyboardType: unit == 'oz'
                          ? const TextInputType.numberWithOptions(decimal: true)
                          : TextInputType.number,
                      inputFormatters: [
                        unit == 'oz'
                            ? FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              )
                            : FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: TextStyle(color: ob.textPrimary, fontSize: 16),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '',
                      ),
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  AppText(
                    unit,
                    style: TextStyle(color: ob.textPrimary, fontSize: 14),
                  ),
                ],
              ),
              const AppSpacerH(32),
              AppRow(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'cancel'.tr,
                      outlined: true,
                      onPressed: () => Navigator.pop(ctx),
                      height: 44,
                    ),
                  ),
                  const AppSpacerW(12),
                  Expanded(
                    child: PrimaryButton(
                      text: 'ok'.tr,
                      useGradient: true,
                      enabled: controller.text.trim().isNotEmpty,
                      onPressed: () {
                        final val = double.tryParse(controller.text);
                        if (val == null || val <= 0) return;
                        final double valInMl = unit == 'oz'
                            ? UnitConverter.ozToMl(val)
                            : val;
                        Navigator.pop(ctx, valInMl);
                      },
                      height: 44,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
    if (result != null) {
      widget.onDrink(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.drinkType;
    final ob = OnboardingTheme.of(context);

    return AppColumn(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(type.imagePath, width: 96, height: 96, fit: BoxFit.contain),
        AppSpacerH(8),
        ...type.descriptions.map(
          (desc) => AppRow(
            crossAxisAlignment: CrossAxisAlignment.start,
            modifier: Modifier.padding(horizontal: 8),
            children: [
              AppText(
                '  •  ',
                style: TextStyle(color: ob.textPrimary, fontSize: 14),
              ),
              Expanded(
                child: AppText(
                  desc.tr,
                  style: TextStyle(
                    color: ob.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const AppSpacerH(24),
        Container(
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
            children: [
              ...List.generate(_presetAmounts.length, (i) {
                final amount = _presetAmounts[i];
                final icon = _presetIcons[i];
                final isSelected = !_isCustom && _selectedAmount == amount;
                final unit = Get.find<SettingsController>().volumeUnit.value;
                return _buildVolumeButton(
                  label: UnitConverter.formatVolumeValueUnit(
                    amount.toDouble(),
                    unit,
                  ),
                  icon: icon,
                  isSelected: isSelected,
                  onTap: () => setState(() {
                    _selectedAmount = amount;
                    _isCustom = false;
                  }),
                );
              }),
              _buildVolumeButton(
                label: 'custom'.tr,
                icon: 'assets/images/svg/ic_edit_water.svg',
                isSelected: _isCustom,
                onTap: _showCustomDialog,
              ),
            ],
          ),
        ),
        const AppSpacerH(24),
        PrimaryButton(
          text: 'drink'.tr,
          width: double.infinity,
          leading: const AppIcon('assets/images/svg/ic_plus.svg', size: 24),
          useGradient: true,
          backgroundDecorations: [
            Positioned(left: 10, top: 24, child: _buildBubble(14)),
            Positioned(left: 24, bottom: -6, child: _buildBubble(20)),
            Positioned(left: 24, top: 16, child: _buildBubble(8)),
            Positioned(right: 20, top: 12, child: _buildBubble(6)),
            Positioned(right: 6, bottom: 30, child: _buildBubble(8)),
            Positioned(right: 5, top: 24, child: _buildBubble(14)),
          ],
          onPressed: () => widget.onDrink(_selectedAmount.toDouble()),
        ),
      ],
    );
  }

  Widget _buildVolumeButton({
    required String label,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
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
          child: AppColumn(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(
                icon,
                size: 24,
                tint: isSelected ? ob.accent : ob.iconAmountWater,
              ),
              const AppSpacerH(4),
              AppText(
                label,
                style: TextStyle(
                  fontSize: 14,
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

  Widget _buildBubble(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.1),
      ),
      child: Stack(
        children: [
          Positioned(
            left: size * 0.2,
            top: size * 0.2,
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

