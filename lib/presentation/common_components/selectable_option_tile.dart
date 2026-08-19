import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/values/app_colors.dart';

/// A card row with an icon, a label and a radio mark, used for the onboarding
/// choice lists on the gradient background.
class SelectableOptionTile extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableOptionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.neutral500.withValues(alpha: isSelected ? 0.3 : 0.22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary500Dark
                : AppColors.basic500.withValues(alpha: 0.14),
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary500Dark.withValues(alpha: 0.4),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: AppRow(
          children: [
            AppIcon(icon, size: 30),
            AppSpacerW16,
            Expanded(
              child: AppText(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.basic500,
                ),
              ),
            ),
            AppSpacerW12,
            RadioMark(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}

/// Filled check when selected, hollow ring otherwise.
class RadioMark extends StatelessWidget {
  final bool isSelected;
  final double size;

  const RadioMark({super.key, required this.isSelected, this.size = 26});

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.gradientRadioSelected,
        ),
        child: Icon(
          Icons.check,
          size: size * 0.62,
          color: AppColors.basic500,
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.basic500.withValues(alpha: 0.35),
          width: 1.6,
        ),
      ),
    );
  }
}
