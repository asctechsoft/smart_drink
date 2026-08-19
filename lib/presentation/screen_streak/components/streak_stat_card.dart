import 'package:dsp_base/app_material.dart';
import 'package:flutter/material.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';

/// Small square card used by the "Total days tracked" / "Longest streak" pair.
class StreakStatCard extends StatelessWidget {
  const StreakStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final String caption;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ob.bgOption,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ob.borderTabHistory, width: 1),
        boxShadow: ob.cardGlowShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ob.textPrimary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 26,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        color: ob.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      caption,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: ob.textPrimary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withValues(alpha: 0.18),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
