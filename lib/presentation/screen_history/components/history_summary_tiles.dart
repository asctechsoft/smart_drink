import 'package:dsp_base/app_material.dart';
import 'package:flutter/material.dart';
import 'package:waternudge/values/onboarding_theme.dart';

/// One of the three "Tổng kết" tiles: an icon, the figure, and its caption.
class HistorySummaryTile extends StatelessWidget {
  const HistorySummaryTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ob.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            caption,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: ob.textPrimary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// The row of three tiles, laid out at a shared height.
class HistorySummaryTiles extends StatelessWidget {
  const HistorySummaryTiles({super.key, required this.tiles});

  final List<HistorySummaryTile> tiles;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: tiles[i]),
          ],
        ],
      ),
    );
  }
}
