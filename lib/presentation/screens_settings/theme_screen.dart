import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/presentation/common_components/custom_switch.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/presentation/common_components/toggle_selector.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final ob = OnboardingTheme.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
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
            'theme'.tr,
            style: TextStyle(
              color: ob.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Obx(
                    () => Column(
                      children: [
                        // Preview
                        AppIcon(
                          isDark
                              ? 'assets/images/webp/img_theme_dark.webp'
                              : 'assets/images/webp/img_theme_light.webp',
                          size: 360,
                        ),
                        AppSpacerH(48),
                        // Light / Dark buttons
                        ToggleSelector(
                          options: ['light'.tr, 'dark'.tr],
                          icons: const [
                            'assets/images/svg/ic_light.svg',
                            'assets/images/svg/ic_dark.svg',
                          ],
                          selectedIndex: isDark ? 1 : 0,
                          isExpanded: true,
                          onChanged: (i) {
                            controller.setThemeMode(i == 0 ? 'light' : 'dark');
                          },
                        ),
                        AppSpacerH12,
                        // Follow system
                        AppRow(
                          modifier: Modifier.appClickable(
                            onTap: () {
                              if (controller.themeMode.value == 'system') {
                                controller.setThemeMode(
                                  isDark ? 'dark' : 'light',
                                );
                              } else {
                                controller.setThemeMode('system');
                              }
                            },
                            radius: 16,
                          ).padding(horizontal: 16, vertical: 12),
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              'follow_the_system'.tr,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ob.textPrimary,
                              ),
                            ),
                            CustomSwitch(
                              value: controller.themeMode.value == 'system',
                              activeColor: ob.switchActive,
                              trackColor: ob.switchTrack,
                              onChanged: (v) {
                                if (v) {
                                  controller.setThemeMode('system');
                                } else {
                                  controller.setThemeMode(
                                    isDark ? 'dark' : 'light',
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

