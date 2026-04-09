import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/controller/user_profile_controller.dart';
import 'package:smartdrinkai/presentation/common_components/gender_card.dart';
import 'package:smartdrinkai/presentation/common_components/primary_bottom_sheet.dart';
import 'package:smartdrinkai/presentation/common_components/toggle_selector.dart';
import 'package:smartdrinkai/presentation/common_components/wheel_picker.dart';
import 'package:smartdrinkai/utils/unit_converter.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';

// Helpers removed - using PrimaryBottomSheet instead

// ─── Gender Sheet ─────────────────────────────────────────────────────────────

void showGenderSheet(BuildContext context) {
  final ctrl = Get.find<UserProfileController>();
  String selected = ctrl.profile.value.gender;
  PrimaryBottomSheet.show(
    context: context,
    title: 'gender',
    buttonText: 'save',
    onButtonPressed: () {
      ctrl.updateGender(selected);
      Navigator.pop(context);
    },
    content: StatefulBuilder(
      builder: (ctx, setState) => AppRow(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GenderCard(
            label: 'male',
            icon: 'assets/images/webp/ic_male.webp',
            isSelected: selected == 'male',
            onTap: () => setState(() => selected = 'male'),
          ),
          AppSpacerW16,
          GenderCard(
            label: 'female',
            icon: 'assets/images/webp/ic_female.webp',
            isSelected: selected == 'female',
            onTap: () => setState(() => selected = 'female'),
          ),
        ],
      ),
    ),
  );
}

// ─── Weight Sheet ─────────────────────────────────────────────────────────────

void showWeightSheet(BuildContext context) {
  final ctrl = Get.find<UserProfileController>();
  final settingsCtrl = Get.find<SettingsController>();
  String unit = ctrl.profile.value.weightUnit;
  int displayValue = ctrl.profile.value.weight.round();

  PrimaryBottomSheet.show(
    context: context,
    title: 'weight',
    buttonText: 'save',
    onButtonPressed: () {
      ctrl.updateWeight(displayValue.toDouble(), unit);
      settingsCtrl.setWeightUnit(unit);
      Navigator.pop(context);
    },
    content: StatefulBuilder(
      builder: (ctx, setState) {
        final minVal = unit == 'kg' ? 20 : 44;
        final maxVal = unit == 'kg' ? 200 : 441;
        displayValue = displayValue.clamp(minVal, maxVal);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ToggleSelector(
              options: const ['kg', 'lb'],
              selectedIndex: unit == 'kg' ? 0 : 1,
              onChanged: (i) {
                final newUnit = i == 0 ? 'kg' : 'lb';
                if (newUnit != unit) {
                  setState(() {
                    if (newUnit == 'lb') {
                      displayValue = UnitConverter.kgToLb(
                        displayValue.toDouble(),
                      ).round();
                    } else {
                      displayValue = UnitConverter.lbToKg(
                        displayValue.toDouble(),
                      ).round();
                    }
                    unit = newUnit;
                  });
                }
              },
            ),
            AppSpacerH24,
            WheelPicker(
              key: ValueKey(unit),
              minValue: minVal,
              maxValue: maxVal,
              initialValue: displayValue,
              onChanged: (v) => displayValue = v,
              suffix: unit,
              showIndicator: true,
              textColor: Colors.white,
              suffixColor: Colors.white70,
            ),
          ],
        );
      },
    ),
  );
}

// ─── Height Sheet ─────────────────────────────────────────────────────────────

/* void showHeightSheet(BuildContext context) {
  final ctrl = Get.find<UserProfileController>();
  final settingsCtrl = Get.find<SettingsController>();
  String unit = ctrl.profile.value.heightUnit;

  // Always work in cm internally for the picker
  int heightCm;
  if (unit == 'm') {
    heightCm = (ctrl.profile.value.height * 100).round();
  } else {
    heightCm = ctrl.profile.value.height.round();
  }

  PrimaryBottomSheet.show(
    context: context,
    title: 'height',
    buttonText: 'save',
    onButtonPressed: () {
      double savedHeight;
      if (unit == 'm') {
        savedHeight = heightCm / 100;
      } else {
        savedHeight = heightCm.toDouble();
      }
      ctrl.saveProfile(
        ctrl.profile.value.copyWith(height: savedHeight, heightUnit: unit),
      );
      settingsCtrl.setHeightUnit(unit);
      Navigator.pop(context);
    },
    content: StatefulBuilder(
      builder: (ctx, setState) => Column(
        children: [
          ToggleSelector(
            options: const ['cm', 'm'],
            selectedIndex: unit == 'cm' ? 0 : 1,
            onChanged: (i) {
              setState(() => unit = i == 0 ? 'cm' : 'm');
            },
          ),
          const SizedBox(height: 8),
          WheelPicker(
            key: ValueKey(unit),
            minValue: 100,
            maxValue: 250,
            initialValue: heightCm.clamp(100, 250),
            onChanged: (v) => heightCm = v,
            suffix: unit,
            showIndicator: true,
            textColor: Colors.white,
            suffixColor: Colors.white70,
            labelBuilder: unit == 'm'
                ? (v) => (v / 100).toStringAsFixed(2)
                : null,
          ),
        ],
      ),
    ),
  );
} */

// ─── Age Sheet ────────────────────────────────────────────────────────────────

/* void showAgeSheet(BuildContext context) {
  final ctrl = Get.find<UserProfileController>();
  int age = ctrl.profile.value.age;
  PrimaryBottomSheet.show(
    context: context,
    title: 'age',
    buttonText: 'save',
    onButtonPressed: () {
      ctrl.updateAge(age);
      Navigator.pop(context);
    },
    content: WheelPicker(
      minValue: 10,
      maxValue: 100,
      initialValue: age,
      onChanged: (v) => age = v,
      textColor: Colors.white,
    ),
  );
} */

// ─── Daily Goal Sheet ─────────────────────────────────────────────────────────

void showDailyGoalSheet(BuildContext context) {
  final ctrl = Get.find<UserProfileController>();
  final settingsCtrl = Get.find<SettingsController>();
  String unit = ctrl.profile.value.volumeUnit;
  final goalMl = ctrl.profile.value.dailyGoalMl;

  // Convert stored ml to display unit
  int displayValue;
  if (unit == 'oz') {
    displayValue = UnitConverter.mlToOz(goalMl.toDouble()).round();
  } else {
    displayValue = goalMl;
  }

  PrimaryBottomSheet.show(
    context: context,
    title: 'daily_goal',
    buttonText: 'save',
    onButtonPressed: () {
      int savedMl;
      if (unit == 'oz') {
        savedMl = UnitConverter.ozToMl(displayValue.toDouble()).round();
      } else {
        savedMl = displayValue;
      }
      ctrl.saveProfile(
        ctrl.profile.value.copyWith(dailyGoalMl: savedMl, volumeUnit: unit),
      );
      settingsCtrl.setVolumeUnit(unit);
      Navigator.pop(context);
    },
    content: StatefulBuilder(
      builder: (ctx, setState) {
        final minVal = unit == 'ml' ? 500 : 16;
        final maxVal = unit == 'ml' ? 8000 : 270;
        displayValue = displayValue.clamp(minVal, maxVal);

        return Column(
          children: [
            ToggleSelector(
              options: const ['ml', 'oz'],
              selectedIndex: unit == 'ml' ? 0 : 1,
              onChanged: (i) {
                final newUnit = i == 0 ? 'ml' : 'oz';
                if (newUnit != unit) {
                  setState(() {
                    if (newUnit == 'oz') {
                      displayValue = UnitConverter.mlToOz(
                        displayValue.toDouble(),
                      ).round();
                    } else {
                      displayValue = UnitConverter.ozToMl(
                        displayValue.toDouble(),
                      ).round();
                    }
                    unit = newUnit;
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            WheelPicker(
              key: ValueKey(unit),
              minValue: minVal,
              maxValue: maxVal,
              initialValue: displayValue,
              onChanged: (v) => displayValue = v,
              suffix: unit,
              showIndicator: true,
              textColor: Colors.white,
              suffixColor: Colors.white70,
              step: unit == 'ml' ? 50 : 1,
            ),
          ],
        );
      },
    ),
  );
}

// ─── Units Sheet ──────────────────────────────────────────────────────────────

void showUnitsSheet(BuildContext context) {
  final settingsCtrl = Get.find<SettingsController>();
  final profileCtrl = Get.find<UserProfileController>();

  String tempVolumeUnit = settingsCtrl.volumeUnit.value;
  String tempWeightUnit = settingsCtrl.weightUnit.value;

  PrimaryBottomSheet.show(
    context: context,
    title: 'units',
    buttonText: 'save',
    onButtonPressed: () {
      // 1. Update SettingsController
      if (tempVolumeUnit != settingsCtrl.volumeUnit.value) {
        settingsCtrl.setVolumeUnit(tempVolumeUnit);
      }
      if (tempWeightUnit != settingsCtrl.weightUnit.value) {
        settingsCtrl.setWeightUnit(tempWeightUnit);
      }

      // 2. Update UserProfile if units changed
      final p = profileCtrl.profile.value;
      double newWeight = p.weight;
      bool changed = false;

      // Handle Weight Conversion
      if (p.weightUnit != tempWeightUnit) {
        if (tempWeightUnit == 'lb') {
          newWeight = UnitConverter.kgToLb(p.weight);
        } else {
          newWeight = UnitConverter.lbToKg(p.weight);
        }
        changed = true;
      }

      if (p.volumeUnit != tempVolumeUnit) {
        changed = true;
      }

      if (changed) {
        profileCtrl.saveProfile(
          p.copyWith(
            volumeUnit: tempVolumeUnit,
            weight: newWeight,
            weightUnit: tempWeightUnit,
          ),
        );
      }

      Navigator.pop(context);
    },
    content: StatefulBuilder(
      builder: (ctx, setState) {
        final ob = OnboardingTheme.of(ctx);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Water unit
            _unitRow(
              'water',
              const ['ml', 'oz'],
              tempVolumeUnit,
              (val) => setState(() => tempVolumeUnit = val),
              ctx,
            ),
            AppSpacerH8,
            Divider(height: 1, thickness: 1, color: ob.divider),
            AppSpacerH8,
            // Weight unit
            _unitRow(
              'weight',
              const ['kg', 'lb'],
              tempWeightUnit,
              (val) => setState(() => tempWeightUnit = val),
              ctx,
            ),
          ],
        );
      },
    ),
  );
}

Widget _unitRow(
  String label,
  List<String> options,
  String currentValue,
  ValueChanged<String> onChanged,
  BuildContext context,
) {
  final ob = OnboardingTheme.of(context);
  return AppRow(
    modifier: Modifier.padding(vertical: 12),
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      AppText(
        label.tr,
        style: TextStyle(
          color: ob.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      _SmallUnitToggle(
        options: options,
        currentValue: currentValue,
        onChanged: onChanged,
      ),
    ],
  );
}

class _SmallUnitToggle extends StatelessWidget {
  final List<String> options;
  final String currentValue;
  final ValueChanged<String> onChanged;

  const _SmallUnitToggle({
    required this.options,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return AppRow(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < options.length; i++) ...[
          if (i > 0) AppSpacerW4,
          AppBoxCentered(
            modifier:
                Modifier.appClickable(
                      onTap: () => onChanged(options[i]),
                      radius: 100,
                    )
                    .width(72)
                    .height(36)
                    .background(
                      color: options[i] == currentValue
                          ? ob.switchActive
                          : ob.bgToggle,
                      radius: 100,
                    ),
            children: [
              AppText(
                options[i],
                style: TextStyle(
                  color: options[i] == currentValue
                      ? ob.textToggleActive
                      : ob.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Time Format Sheet ────────────────────────────────────────────────────────

void showTimeFormatSheet(BuildContext context) {
  final ctrl = Get.find<SettingsController>();

  String getFormat(int index) {
    if (index == 1) return '12h';
    if (index == 2) return 'system';
    return '24h';
  }

  int getIndex(String format) {
    if (format == '12h') return 1;
    if (format == 'system') return 2;
    return 0;
  }

  String getLabel(int index) {
    if (index == 1) return 'time_12_hour'.tr;
    if (index == 2) return 'follow_the_system'.tr;
    return 'time_24_hour'.tr;
  }

  int displayValue = getIndex(ctrl.timeFormat.value);

  PrimaryBottomSheet.show(
    context: context,
    title: 'time_format',
    buttonText: 'save',
    onButtonPressed: () {
      ctrl.setTimeFormat(getFormat(displayValue));
      Navigator.pop(context);
    },
    content: StatefulBuilder(
      builder: (ctx, setState) => WheelPicker(
        minValue: 0,
        maxValue: 2,
        initialValue: displayValue,
        onChanged: (v) => displayValue = v,
        labelBuilder: getLabel,
        showIndicator: false,
        textColor: Colors.white,
        itemWidth: 250,
        isLooping: true,
        visibleItemCount: 3,
      ),
    ),
  );
}

