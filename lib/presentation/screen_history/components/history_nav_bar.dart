import 'package:dsp_base/app_material.dart';
import 'package:flutter/material.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';

/// `‹  label  ›` strip that sits above the charts on every history tab.
///
/// [trailingIcon] renders next to the label — a calendar on the day tab, a
/// caret on the month/year tabs — and makes the label tappable.
class HistoryNavBar extends StatelessWidget {
  const HistoryNavBar({
    super.key,
    required this.label,
    required this.onPrevious,
    required this.onNext,
    required this.canGoNext,
    this.trailingIcon,
    this.onLabelTap,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool canGoNext;
  final IconData? trailingIcon;
  final VoidCallback? onLabelTap;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          _Arrow(icon: Icons.chevron_left_rounded, onTap: onPrevious),
          Expanded(
            child: GestureDetector(
              onTap: onLabelTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ob.textPrimary,
                      ),
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 6),
                    Icon(
                      trailingIcon,
                      size: 17,
                      color: ob.textPrimary.withValues(alpha: 0.75),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Opacity(
            opacity: canGoNext ? 1 : 0,
            child: _Arrow(
              icon: Icons.chevron_right_rounded,
              onTap: canGoNext ? onNext : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icon, size: 26, color: ob.textPrimary),
      ),
    );
  }
}
