import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/today_controller.dart';
import 'package:smartdrinkai/models/ui_models/drink_type.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/presentation/screen_today/components/drink_selection_bottom_sheet.dart';
import 'package:smartdrinkai/utils/toast_utils.dart';
import 'package:get/get.dart';

class AddDrinkButton extends StatelessWidget {
  const AddDrinkButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PrimaryButton(
        text: 'add_drink'.tr,
        useGradient: true,
        autoSizeText: false,
        onPressed: () => _showAddDrinkSheet(context),
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
        height: null,
        leading: const AppIcon('assets/images/svg/ic_plus.svg', size: 24),
        backgroundDecorations: [
          Positioned(left: 10, top: 24, child: _buildBubble(14)),
          Positioned(left: 24, bottom: -6, child: _buildBubble(20)),
          Positioned(left: 24, top: 16, child: _buildBubble(8)),
          Positioned(right: 20, top: 12, child: _buildBubble(6)),
          Positioned(right: 6, bottom: 30, child: _buildBubble(8)),
          Positioned(right: 5, top: 24, child: _buildBubble(14)),
        ],
      ),
    );
  }

  void _showAddDrinkSheet(BuildContext context) {
    DrinkSelectionBottomSheet.show(
      context: context,
      drinkType: DrinkType.water,
      onDrink: (amount) async {
        final controller = Get.find<TodayController>();
        final effectiveWater =
            (amount * DrinkType.water.waterPercent / 100).round();
        if (controller.currentIntakeMl.value + effectiveWater > 8000) {
          ToastUtils.showLimitToast(context);
          return;
        }
        Get.back();
        await controller.addDrink(
          effectiveWater,
          originalAmountMl: amount,
          drinkType: DrinkType.water.name,
        );
      },
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
