import 'package:dsp_base/app_material.dart';
import 'package:flutter/material.dart';
import 'package:waternudge/values/onboarding_theme.dart';

/// Section heading used above every block on the history screen.
class HistorySectionTitle extends StatelessWidget {
  const HistorySectionTitle(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white60,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Card wrapper shared by the history blocks that sit on the app gradient.
class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: child,
    );
  }
}

/// "Ngày uống nhiều nhất" — one labelled row with the record value.
class HistoryHighlightCard extends StatelessWidget {
  const HistoryHighlightCard({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);

    return HistoryCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(Icons.water_drop_rounded, size: 20, color: ob.switchActive),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ob.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ob.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
