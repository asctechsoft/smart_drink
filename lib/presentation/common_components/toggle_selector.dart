import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ToggleSelector extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<String>? icons;
  final double? itemWidth;
  final bool isExpanded;

  const ToggleSelector({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.icons,
    this.itemWidth,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return AppRow(
      modifier: Modifier.background(
        color: ob.bgToggle,
        radius: 48,
      ).border(color: ob.borderTabHistory, width: 1, radius: 48).paddingAll(4),
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      children: List.generate(options.length, (index) {
        final isSelected = index == selectedIndex;
        Widget childWidget = AppRow(
          modifier:
              Modifier.appClickable(onTap: () => onChanged(index), radius: 48)
                  .conditional(
                    !isExpanded,
                    onTrue: (m) => m.width(itemWidth ?? 100),
                  )
                  .background(
                    color: isSelected ? ob.switchActive : Colors.transparent,
                    radius: 48,
                  )
                  .padding(horizontal: 24, vertical: 10),
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
                fontSize: 16,
                color: isSelected ? ob.textToggleActive : ob.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
        return isExpanded ? Expanded(child: childWidget) : childWidget;
      }),
    );
  }
}

