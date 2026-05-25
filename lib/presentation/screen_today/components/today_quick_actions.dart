import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/controller/today_controller.dart';
import 'package:smartdrinkai/models/ui_models/activity_level.dart';
import 'package:smartdrinkai/models/ui_models/weather_condition.dart';
import 'package:smartdrinkai/presentation/common_components/primary_bottom_sheet.dart';
import 'package:smartdrinkai/utils/unit_converter.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';

class TodayQuickActions extends StatelessWidget {
  const TodayQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodayController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _QuickActionButton(
          icon: 'assets/images/svg/ic_run.svg',
          onTap: () => _showActivityBottomSheet(context, controller),
        ),
        const AppSpacerW(104),
        _QuickActionButton(
          icon: 'assets/images/svg/ic_sun.svg',
          onTap: () => _showWeatherBottomSheet(context, controller),
        ),
      ],
    );
  }

  void _showActivityBottomSheet(
    BuildContext context,
    TodayController controller,
  ) {
    const activityIcons = {
      ActivityLevel.sedentary:
          'assets/images/svg/ic_airline_seat_recline_extra.svg',
      ActivityLevel.lightActive: 'assets/images/svg/ic_directions_walk.svg',
      ActivityLevel.moderateActive: 'assets/images/svg/ic_directions_run.svg',
      ActivityLevel.veryActive: 'assets/images/svg/ic_directions_run_fast.svg',
    };

    ActivityLevel selectedLevel = controller.activityLevel;

    PrimaryBottomSheet.show(
      context: context,
      title: 'physical_activity'.tr,
      buttonText: 'save'.tr,
      onButtonPressed: () {
        controller.setActivityLevel(selectedLevel);
        Navigator.pop(context);
      },
      content: StatefulBuilder(
        builder: (context, setState) {
          return AppColumn(
            children: ActivityLevel.values.asMap().entries.map((entry) {
              final index = entry.key;
              final level = entry.value;
              final ob = OnboardingTheme.of(context);
              return AppColumn(
                children: [
                  if (index > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(height: 1, color: ob.bgOptionSelected),
                    ),
                  _buildOptionRow(
                    icon: activityIcons[level]!,
                    title: () {
                      final unit =
                          Get.find<SettingsController>().volumeUnit.value;
                      return '${level.label.tr} (${UnitConverter.formatVolumeValueUnit(level.extraMl.toDouble(), unit)})';
                    }(),
                    subtitle: level.description.tr,
                    selected: selectedLevel == level,
                    onTap: () {
                      setState(() {
                        selectedLevel = level;
                      });
                    },
                    context: context,
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showWeatherBottomSheet(
    BuildContext context,
    TodayController controller,
  ) {
    const weatherIcons = {
      WeatherCondition.cold: 'assets/images/svg/ic_wather_cold.svg',
      WeatherCondition.normal: 'assets/images/svg/ic_wather_normal.svg',
      WeatherCondition.warm: 'assets/images/svg/ic_wather_warm.svg',
      WeatherCondition.hot: 'assets/images/svg/ic_wather_hot.svg',
    };

    WeatherCondition selectedCondition = controller.weatherCondition;

    PrimaryBottomSheet.show(
      context: context,
      title: 'weather'.tr,
      buttonText: 'save'.tr,
      onButtonPressed: () {
        controller.setWeatherCondition(selectedCondition);
        Navigator.pop(context);
      },
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: WeatherCondition.values.asMap().entries.map((entry) {
              final index = entry.key;
              final condition = entry.value;
              final ob = OnboardingTheme.of(context);
              return Column(
                children: [
                  if (index > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(height: 1, color: ob.bgOptionSelected),
                    ),
                  _buildOptionRow(
                    icon: weatherIcons[condition]!,
                    title: () {
                      final unit =
                          Get.find<SettingsController>().volumeUnit.value;
                      return '${condition.label.tr} (${UnitConverter.formatVolumeValueUnit(condition.extraMl.toDouble(), unit)})';
                    }(),
                    subtitle: condition.description.tr,
                    selected: selectedCondition == condition,
                    onTap: () {
                      setState(() {
                        selectedCondition = condition;
                      });
                    },
                    context: context,
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildOptionRow({
    required String icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final ob = OnboardingTheme.of(context);
    return AppRow(
      modifier: Modifier.appClickable(onTap: onTap, radius: 12).paddingAll(12),
      children: [
        AppIcon(icon, size: 24),
        AppSpacerW(12),
        AppColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          modifier: Modifier.weight(1),
          children: [
            AppText(
              title.tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ob.textPrimary,
                letterSpacing: 0.7,
              ),
            ),
            AppText(
              subtitle.tr,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ob.textSecondary,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const AppSpacerW(20),
        _buildRadioIndicator(selected, context),
      ],
    );
  }

  Widget _buildRadioIndicator(bool selected, BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ob.accent, width: 1),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ob.accent,
                ),
              ),
            )
          : null,
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const _QuickActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return AppBoxCentered(
      modifier: Modifier.appClickable(onTap: onTap, radius: 8)
          .background(color: ob.bgOption, radius: 8)
          .border(color: ob.borderTabHistory, width: 1, radius: 8)
          .paddingAll(8),
      children: [AppIcon(icon, size: 32, tint: ob.iconPill)],
    );
  }
}

