import 'package:dsp_base/app_material.dart';
import 'package:waternudge/values/app_colors.dart';
import 'package:waternudge/values/onboarding_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ToggleSelector extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<String>? icons;
  final double? itemWidth;
  final bool isExpanded;
  final bool compact;

  /// Styles the selector for the app's gradient backgrounds: a dark translucent
  /// track with a bright gradient pill on the selected option.
  final bool onGradient;

  const ToggleSelector({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.icons,
    this.itemWidth,
    this.isExpanded = false,
    this.onGradient = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final trackColor = onGradient
        ? AppColors.neutral500.withValues(alpha: 0.35)
        : ob.bgToggle;
    final trackBorder = onGradient
        ? AppColors.basic500.withValues(alpha: 0.12)
        : ob.borderTabHistory;

    return AppRow(
      modifier: Modifier.background(
        color: trackColor,
        radius: 48,
      ).border(color: trackBorder, width: 1, radius: 48).paddingAll(4),
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      children: List.generate(options.length, (index) {
        final isSelected = index == selectedIndex;
        Widget childWidget = AppRow(
          modifier:
              Modifier.appClickable(onTap: () => onChanged(index), radius: 48)
                  .conditional(
                    !isExpanded,
                    onTrue: (m) => m.width(itemWidth ?? (compact ? 68 : 100)),
                  )
                  .background(
                    color: isSelected && !onGradient
                        ? ob.switchActive
                        : Colors.transparent,
                    radius: 48,
                  )
                  .padding(
                    horizontal: compact ? 12 : 24,
                    vertical: compact ? 7 : 10,
                  ),
          mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icons != null && index < icons!.length) ...[
              SvgPicture.asset(icons![index], width: 20, height: 20),
              AppSpacerW4,
            ],
            AppText(
              options[index],
              style: TextStyle(
                fontSize: compact ? 13 : 16,
                color: onGradient
                    ? (isSelected
                          ? AppColors.basic500
                          : AppColors.basic500.withValues(alpha: 0.65))
                    : (isSelected ? ob.textToggleActive : ob.textPrimary),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
        if (onGradient && isSelected) {
          childWidget = DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.gradientAccentPill,
              borderRadius: BorderRadius.circular(48),
            ),
            child: childWidget,
          );
        }
        return isExpanded ? Expanded(child: childWidget) : childWidget;
      }),
    );
  }
}
