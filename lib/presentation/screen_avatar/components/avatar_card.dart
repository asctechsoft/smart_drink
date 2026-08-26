import 'package:dsp_base/app_material.dart';
import 'package:flutter/material.dart';
import 'package:waternudge/models/ui_models/avatar_option.dart';
import 'package:waternudge/values/app_colors.dart';
import 'package:waternudge/values/onboarding_theme.dart';

/// One tile on the avatar grid.
///
/// The artwork is not shipped yet, so an option without an [AvatarOption.asset]
/// renders as an empty card — the frame, selection state and check badge all
/// still work, and dropping the image in later needs no change here.
class AvatarCard extends StatelessWidget {
  const AvatarCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final AvatarOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary500Dark.withValues(alpha: 0.12)
              : ob.bgOption,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary500Dark : ob.borderTabHistory,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: ob.cardGlowShadow,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: option.asset == null
                    ? const SizedBox.shrink()
                    : Image.asset(option.asset!, fit: BoxFit.contain),
              ),
            ),
            if (isSelected)
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary500Dark,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 15,
                    color: AppColors.neutral500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
