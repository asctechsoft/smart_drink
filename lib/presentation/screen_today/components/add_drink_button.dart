import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/values/route_name.dart';
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
        onPressed: () => Get.toNamed(RouteName.addDrink),
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
        height: null, // Let padding define height
        leading: const AppIcon('assets/images/svg/ic_plus.svg', size: 24),
        backgroundDecorations: [
          // Bubbles - Bên trái
          Positioned(left: 10, top: 24, child: _buildBubble(14)),
          Positioned(left: 24, bottom: -6, child: _buildBubble(20)),
          Positioned(left: 24, top: 16, child: _buildBubble(8)),

          // Bubbles - Bên phải
          Positioned(right: 20, top: 12, child: _buildBubble(6)),
          Positioned(right: 6, bottom: 30, child: _buildBubble(8)),
          Positioned(right: 5, top: 24, child: _buildBubble(14)),
        ],
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

