import 'package:dsp_base/app_material.dart';
import 'package:get/get.dart';
import 'package:smartdrinkai/controller/avatar_controller.dart';
import 'package:smartdrinkai/models/ui_models/avatar_option.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/presentation/common_components/toggle_selector.dart';
import 'package:smartdrinkai/presentation/screen_avatar/components/avatar_card.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';

class AvatarScreen extends StatelessWidget {
  const AvatarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AvatarController>();
    final ob = OnboardingTheme.of(context);

    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            icon: AppIcon(
              'assets/images/svg/ic_back_left.svg',
              size: 24,
              tint: ob.textPrimary,
              autoMirror: true,
            ),
            onPressed: () => Get.back(),
          ),
          centerTitle: false,
          title: AppText(
            'change_avatar'.tr,
            style: TextStyle(
              color: ob.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Obx(
                  () => ToggleSelector(
                    options: ['avatar_human_figure'.tr, 'avatar_body_model'.tr],
                    selectedIndex:
                        controller.category.value == AvatarCategory.humanFigure
                        ? 0
                        : 1,
                    isExpanded: true,
                    onGradient: true,
                    onChanged: (i) => controller.setCategory(
                      i == 0
                          ? AvatarCategory.humanFigure
                          : AvatarCategory.bodyModel,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  final options = AvatarOption.byCategory(
                    controller.category.value,
                  );
                  final selectedId = controller.selectedAvatarId.value;

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      return AvatarCard(
                        option: option,
                        isSelected: option.id == selectedId,
                        onTap: () => controller.select(option.id),
                      );
                    },
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: PrimaryButton(
                  text: 'save_changes'.tr,
                  useGradient: true,
                  width: double.infinity,
                  onPressed: () {
                    controller.save();
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
