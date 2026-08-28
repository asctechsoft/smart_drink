import 'package:dsp_base/app_material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:waternudge/controller/settings_controller.dart';
import 'package:waternudge/models/data_models/daily_summary.dart';
import 'package:waternudge/models/data_models/drink_record.dart';
import 'package:waternudge/models/ui_models/drink_type.dart';
import 'package:waternudge/utils/date_utils.dart';
import 'package:waternudge/utils/unit_converter.dart';
import 'package:waternudge/values/onboarding_theme.dart';

import 'history_section.dart';

/// "Lịch sử chi tiết" heading. On the period tabs it collapses the list; on the
/// day tab the list is always open and [onToggle] is null.
class HistoryDetailHeader extends StatelessWidget {
  const HistoryDetailHeader({
    super.key,
    required this.title,
    this.expanded = true,
    this.onToggle,
  });

  final String title;
  final bool expanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: HistorySectionTitle(
        title,
        trailing: onToggle == null
            ? null
            : Icon(
                expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 14,
                color: ob.textPrimary.withValues(alpha: 0.8),
              ),
      ),
    );
  }
}

class DrinkRecordRow extends StatelessWidget {
  const DrinkRecordRow({
    super.key,
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  final DrinkRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final settings = Get.find<SettingsController>();
    final type = DrinkType.values.firstWhere(
      (t) => t.name == record.drinkType,
      orElse: () => DrinkType.water,
    );
    final timeStr = UnitConverter.formatTime(
      '${record.timestamp.hour.toString().padLeft(2, '0')}:'
      '${record.timestamp.minute.toString().padLeft(2, '0')}',
    );
    final displayMl = record.originalAmountMl > 0
        ? record.originalAmountMl
        : record.amountMl.toDouble();
    final amount = UnitConverter.formatVolumeValueUnit(
      displayMl,
      settings.volumeUnit.value,
    );

    return Slidable(
      key: ValueKey(
        'record-${record.id ?? record.timestamp.microsecondsSinceEpoch}',
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.4,
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: Colors.transparent,
            foregroundColor: Color(0xFF96D2A8),
            icon: Icons.edit_outlined,
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.red,
            icon: Icons.delete_outline,
          ),
        ],
      ),
      child: HistoryCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Image.asset(
              type.imagePath,
              fit: BoxFit.contain,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                timeStr,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ob.textPrimary,
                ),
              ),
            ),
            SizedBox(
              width: 64,
              child: Text(
                amount,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ob.textPrimary.withValues(alpha: 0.9),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 88,
              child: Text(
                type.label.tr,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 12,
                  color: ob.textPrimary.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: Color(0xFF96D2A8),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wraps a [DrinkRecordRow] so that deleting it collapses (height → 0) and
/// fades out, letting the rows below slide up smoothly, before the underlying
/// record is actually removed. Uses SizeTransition + FadeTransition (cheap,
/// GPU-composited) to stay jank-free.
class RemovableRecordRow extends StatefulWidget {
  const RemovableRecordRow({
    super.key,
    required this.record,
    required this.onEdit,
    required this.onDelete,
    this.gap = 8,
  });

  final DrinkRecord record;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;
  final double gap;

  @override
  State<RemovableRecordRow> createState() => _RemovableRecordRowState();
}

class _RemovableRecordRowState extends State<RemovableRecordRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;
  bool _removing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: 1, // fully visible; only removal animates
    );
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    if (_removing) return;
    setState(() => _removing = true);
    await _controller.reverse(); // 1 → 0: collapse + fade
    await widget.onDelete(); // now drop it from the data source
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _anim,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: _anim,
        child: Padding(
          padding: EdgeInsets.only(bottom: widget.gap),
          child: DrinkRecordRow(
            record: widget.record,
            onEdit: widget.onEdit,
            onDelete: _handleDelete,
          ),
        ),
      ),
    );
  }
}

/// One row inside the week / month / year detail list: a period label, what
/// was drunk against that period's goal, and a progress bar. The week and
/// month tabs pass single days; the year tab passes whole months.
class PeriodSummaryRow extends StatelessWidget {
  const PeriodSummaryRow({
    super.key,
    required this.label,
    required this.totalMl,
    required this.goalMl,
  });

  final String label;
  final int totalMl;
  final int goalMl;

  /// Builds a row for one stored day, falling back to today's goal when the
  /// summary predates the stored-goal column.
  factory PeriodSummaryRow.fromSummary(
    DailySummary summary,
    int fallbackGoalMl,
  ) {
    final date = DateTime.tryParse(summary.dateKey);
    return PeriodSummaryRow(
      label: date != null ? AppDateUtils.formatViDate(date) : summary.dateKey,
      totalMl: summary.totalMl,
      goalMl: summary.goalMl > 0 ? summary.goalMl : fallbackGoalMl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final unit = Get.find<SettingsController>().volumeUnit.value;
    final progress = goalMl > 0 ? (totalMl / goalMl).clamp(0.0, 1.0) : 0.0;
    final dateLabel = label;

    return HistoryCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dateLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ob.textPrimary,
                  ),
                ),
              ),
              Text(
                UnitConverter.formatVolumeGrouped(totalMl.toDouble(), unit),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ob.switchActive,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ob.textPrimary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: ob.textPrimary.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(ob.switchActive),
            ),
          ),
        ],
      ),
    );
  }
}
