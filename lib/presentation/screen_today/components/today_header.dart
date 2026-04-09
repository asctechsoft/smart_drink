import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/today_controller.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:smartdrinkai/values/route_name.dart';
import 'package:get/get.dart';

class TodayHeader extends StatelessWidget {
  const TodayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final controller = Get.find<TodayController>();

    return AppRow(
      modifier: Modifier.padding(horizontal: 16, vertical: 12),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: AppColumn(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppRow(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: AppTextAutoResize(
                      'stay_hydrated'.tr,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ob.textPrimary,
                        letterSpacing: 0.9,
                      ),
                    ),
                  ),
                  AppSpacerW8,
                  AppIcon(
                    ob.isLight
                        ? 'assets/images/webp/img_noto_sweat_light.webp'
                        : 'assets/images/webp/img_noto_sweat_dark.webp',
                    size: 20,
                  ),
                ],
              ),
              AppText(
                'track_your_water_intake'.tr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: ob.textPrimary,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
        ),
        // Notification bell button
        AppIcon(
          'assets/images/svg/ic_ring.svg',
          size: 28,
          modifier:
              Modifier.appClickable(
                    onTap: () async {
                      await Get.toNamed(RouteName.reminderSettings);
                      controller.loadTodayData();
                    },
                    radius: 8,
                  )
                  .background(color: ob.bgOption, radius: 8)
                  .border(color: ob.borderTabHistory, width: 1, radius: 8)
                  .paddingAll(8),
        ),
      ],
    );
  }
}

