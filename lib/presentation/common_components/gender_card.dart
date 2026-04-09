import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/values/app_colors.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/utils.dart';

class GenderCard extends StatelessWidget {
  final String label;
  final String icon; // asset path, e.g. 'assets/images/webp/ic_male.webp'
  final bool isSelected;
  final VoidCallback onTap;

  const GenderCard({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? AppColors.basic300 : AppColors.neutral300;
    final borderSelected = ob.switchActive;
    final borderUnselected = ob.borderReminderPill;
    final accentColor = ob.switchActive;

    return AppColumn(
      modifier: Modifier.clickable(onTap)
          .width(140)
          .height(166)
          .background(color: cardBg, radius: 12)
          .border(
            color: isSelected ? borderSelected : borderUnselected,
            width: isSelected ? 2 : 1,
            radius: 12,
          )
          .padding(vertical: 4),
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(icon, size: 120),
        AppSpacerH10,
        AppText(
          label.tr,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? accentColor : ob.textPrimary,
          ),
        ),
      ],
    );
  }
}

