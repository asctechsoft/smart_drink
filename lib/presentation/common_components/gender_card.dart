import 'package:dsp_base/app_material.dart';
import 'package:waternudge/values/app_colors.dart';
import 'package:get/utils.dart';

class GenderCard extends StatelessWidget {
  final String label;
  final String icon; // asset path, e.g. 'assets/images/webp/img_men.webp'
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 148,
        height: 208,
        decoration: BoxDecoration(
          color: AppColors.neutral500.withValues(
            alpha: isSelected ? 0.2 : 0.16,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.basic500.withValues(alpha: 0.6)
                : AppColors.basic500.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.basic500.withValues(alpha: 0.15),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: AppColumn(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decode at display size, not the asset's full ~1024px resolution:
            // AppIcon/Image.asset without cacheWidth decoded the whole webp on
            // first show, which stalled this sheet for a noticeable beat.
            Image.asset(
              icon,
              width: 116,
              height: 116,
              fit: BoxFit.contain,
              cacheWidth: (116 * MediaQuery.of(context).devicePixelRatio).round(),
            ),
            AppSpacerH4,
            AppText(
              label.tr,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.basic500
                    : AppColors.basic500.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
