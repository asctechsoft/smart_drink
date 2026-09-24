import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waternudge/controller/today_controller.dart';
import 'package:waternudge/models/ui_models/drink_type.dart';
import 'package:waternudge/presentation/common_components/app_modifier.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';
import 'package:waternudge/presentation/screen_today/components/drink_selection_bottom_sheet.dart';
import 'package:waternudge/utils/analytics.dart';
import 'package:waternudge/utils/toast_utils.dart';
import 'package:waternudge/values/onboarding_theme.dart';
import 'package:get/get.dart';

class AddDrinkScreen extends StatefulWidget {
  const AddDrinkScreen({super.key});

  @override
  State<AddDrinkScreen> createState() => _AddDrinkScreenState();
}

class _AddDrinkScreenState extends State<AddDrinkScreen> {
  DrinkType _selectedType = DrinkType.water;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDrinkBottomSheet(DrinkType.water);
    });
  }

  void _showDrinkBottomSheet(DrinkType type) {
    setState(() => _selectedType = type);
    Analytics.addDrinkScreenView();

    DrinkSelectionBottomSheet.show(
      context: context,
      drinkType: type,
      onDrink: (amount) async {
        final effectiveWater = (amount * type.waterPercent / 100).round();
        final controller = Get.find<TodayController>();
        if (controller.currentIntakeMl.value + effectiveWater > 8000) {
          ToastUtils.showLimitToast(context);
          return;
        }
        Navigator.pop(context); // Close bottom sheet
        await controller.addDrink(
          effectiveWater,
          originalAmountMl: amount,
          drinkType: type.name,
          source: 'add_drink_screen',
        );
        Get.back(); // Back to TodayScreen
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Builder(
              builder: (context) {
                final icon = SvgPicture.asset(
                  'assets/images/svg/ic_back_left.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    ob.textPrimary,
                    BlendMode.srcIn,
                  ),
                );
                return Directionality.of(context) == TextDirection.rtl
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..scale(-1.0, 1, 1),
                        child: icon,
                      )
                    : icon;
              },
            ),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          title: Text(
            'add_drink'.tr,
            style: TextStyle(
              color: ob.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: DrinkType.values.length,
              itemBuilder: (context, index) {
                final type = DrinkType.values[index];
                final isSelected = type == _selectedType;
                return GestureDetector(
                  onTap: () => _showDrinkBottomSheet(type),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        type.imagePath,
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Text(
                          type.emoji,
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        type.label.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ob.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/svg/ic_water_drop.svg',
                            width: 12,
                            height: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${type.waterPercent}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: ob.textPercentDrinkItem,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).apply(
                    Modifier.appClickable(
                          onTap: () => _showDrinkBottomSheet(type),
                        )
                        .background(
                          color: isSelected
                              ? ob.accent.withValues(alpha: 0.15)
                              : ob.bgDrinkItem,
                          radius: 8,
                        )
                        .border(
                          width: isSelected ? 2 : 0,
                          color: isSelected ? ob.accent : Colors.transparent,
                          radius: 8,
                        ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

