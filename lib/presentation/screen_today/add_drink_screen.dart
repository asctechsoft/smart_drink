import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/today_controller.dart';
import 'package:smartdrinkai/models/ui_models/drink_type.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/presentation/screen_today/components/drink_selection_bottom_sheet.dart';
import 'package:smartdrinkai/utils/toast_utils.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
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
            icon: AppIcon(
              'assets/images/svg/ic_back_left.svg',
              size: 24,
              tint: ob.textPrimary,
              autoMirror: true,
            ),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          title: AppText(
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
                  child: AppColumn(
                    mainAxisAlignment: MainAxisAlignment.center,
                    modifier:
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
                              color: isSelected
                                  ? ob.accent
                                  : Colors.transparent,
                              radius: 8,
                            ),
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
                      AppSpacerH6,
                      AppText(
                        type.label.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ob.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppRow(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppIcon(
                            'assets/images/svg/ic_water_drop.svg',
                            size: 12,
                          ),
                          AppSpacerW2,
                          AppText(
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

