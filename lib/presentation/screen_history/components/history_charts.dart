import 'dart:math' as math;

import 'package:dsp_base/app_material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternudge/utils/unit_converter.dart';
import 'package:waternudge/values/app_colors.dart';
import 'package:waternudge/values/onboarding_theme.dart';

/// Shared chart palette and axis maths for the four history tabs.
class _ChartStyle {
  static const Color barTop = Color(0xFF4FC3F7);
  static const Color barBottom = Color(0xFF1E6FE0);
  static const Color goalLine = Color(0xFF9DD6FF);

  static LinearGradient get barGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [barTop, barBottom],
  );

  /// Rounds [rawMax] up to a tidy axis ceiling that divides into [divisions]
  /// equal steps, so the gridlines land on round numbers.
  static double niceMax(double rawMax, {int divisions = 4}) {
    if (rawMax <= 0) return divisions.toDouble();
    final rough = rawMax / divisions;
    final magnitude = _pow10(rough.floor().toString().length - 1);
    for (final m in const [1, 1.5, 2, 2.5, 3, 4, 5, 6, 10]) {
      final step = magnitude * m;
      if (step >= rough) return step * divisions;
    }
    return magnitude * 10 * divisions;
  }

  static double _pow10(int exp) {
    var result = 1.0;
    for (var i = 0; i < exp; i++) {
      result *= 10;
    }
    return result;
  }
}

/// Resolved Y axis for one chart.
class _Axis {
  const _Axis({
    required this.maxY,
    required this.interval,
    required this.showGoal,
  });

  final double maxY;
  final double interval;

  /// Whether the goal line belongs on this chart.
  final bool showGoal;

  /// Scales the axis to the data, letting the goal stretch it only while it
  /// stays within reach of what was actually drunk. A yearly target sitting
  /// 70× above a first day's 790 ml would otherwise flatten every bar onto
  /// the baseline, which is what made the year and month tabs look empty.
  factory _Axis.fit(
    double dataMax,
    double goal, {
    int divisions = 4,
    double headroom = 1.05,
    double floor = 0,
  }) {
    final bool showGoal;
    final double reference;
    if (dataMax <= 0) {
      // Nothing logged yet: the goal is the only meaningful scale.
      showGoal = goal > 0;
      reference = goal > 0 ? goal : floor;
    } else {
      showGoal = goal > 0 && goal <= dataMax * 3;
      reference = showGoal ? math.max(dataMax, goal) : dataMax;
    }
    final maxY = _ChartStyle.niceMax(
      math.max(reference, floor) * headroom,
      divisions: divisions,
    );
    return _Axis(maxY: maxY, interval: maxY / divisions, showGoal: showGoal);
  }
}

/// Y-axis unit caption ("Unit (ml)") drawn above the chart. Styled after the
/// Day tab, which is the reference every history chart follows.
class _AxisUnitLabel extends StatelessWidget {
  const _AxisUnitLabel({required this.unit});

  final String unit;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Unit ($unit)',
        style: const TextStyle(fontSize: 10, color: Colors.white70),
      ),
    );
  }
}

/// Y-axis tick labels for one chart.
///
/// [reservedSize] is measured from the widest tick this chart will actually
/// draw rather than fixed per tab, because fl_chart centres each label inside
/// the reserved gutter: a fixed 34 px gutter looks flush with the "Unit (ml)"
/// caption on the Day tab (four digits, "2000") but leaves the Week tab's
/// three-digit ticks — and the whole plot with them — floating ~14 px to the
/// right. Each label then fills the gutter and right-aligns in it, so the ticks
/// stay lined up against the axis whatever their length.
class _LeftAxis {
  _LeftAxis({
    required this.maxY,
    required this.interval,
    required BuildContext context,
    this.compact = false,
  }) // Resolved against the ambient default so the measurement below uses the
    // very same font the label will be painted with. Measuring with a bare
    // `fontSize: 10` picks up the platform font instead of the app's
    // PlusJakartaSans, whose wider digits then wrap "2000" onto two lines.
    : style = DefaultTextStyle.of(context).style.merge(_baseStyle),
       _scaler = MediaQuery.textScalerOf(context) {
    var widest = 0.0;
    if (interval > 0) {
      // Nudge the bound so the top tick isn't dropped by float drift.
      for (
        var value = 0.0;
        value <= maxY + interval / 1000;
        value += interval
      ) {
        final painter = TextPainter(
          text: TextSpan(text: _format(value, compact), style: style),
          textDirection: TextDirection.ltr,
          textScaler: _scaler,
        )..layout();
        widest = math.max(widest, painter.width);
      }
    }
    reservedSize = widest + _gap + _slack;
  }

  final double maxY;
  final double interval;
  final bool compact;

  /// Style the ticks are both measured and painted with.
  final TextStyle style;

  final TextScaler _scaler;

  /// Width of the widest tick label, its gap to the axis and [_slack].
  late final double reservedSize;

  /// Gap between a tick and the axis it labels.
  static const _gap = 4.0;

  /// Rounding-error cushion. Raise this if a tick ever renders clipped.
  static const _slack = 1.0;

  static const _baseStyle = TextStyle(fontSize: 10, color: Colors.white70);

  static String _format(double value, bool compact) => value <= 0
      ? '0'
      : compact
      ? UnitConverter.formatCompact(value)
      : value.round().toString();

  AxisTitles get titles => AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: reservedSize,
      interval: interval,
      getTitlesWidget: (value, meta) => SizedBox(
        // Filling the gutter is what makes textAlign.right bite — a bare Text
        // shrinks to its glyphs and gets centred instead.
        width: reservedSize,
        child: Padding(
          padding: const EdgeInsets.only(right: _gap),
          child: Text(
            _format(value, compact),
            textAlign: TextAlign.right,
            // The gutter is sized to the widest tick, so a wrap here would
            // only ever be a measurement slip — fail visibly instead.
            maxLines: 1,
            softWrap: false,
            style: style,
          ),
        ),
      ),
    ),
  );
}

/// [verticalInterval] adds vertical rules along the X axis; leave it null to
/// keep horizontal rules only. Only usable on line charts — [BarChartData]
/// pins minX/maxX to 0..1, so vertical grid lines there land nowhere near the
/// bars. Bar charts get [_rodTrack] instead.
FlGridData _grid(
  BuildContext context,
  double interval, {
  double? verticalInterval,
}) {
  final ob = OnboardingTheme.of(context);
  return FlGridData(
    show: true,
    drawVerticalLine: verticalInterval != null,
    verticalInterval: verticalInterval,
    horizontalInterval: interval,
    getDrawingHorizontalLine: (_) =>
        FlLine(color: ob.textPrimary.withValues(alpha: 0.12), strokeWidth: 0.6),
    getDrawingVerticalLine: (_) =>
        FlLine(color: ob.textPrimary.withValues(alpha: 0.18), strokeWidth: 1),
  );
}

/// Faint full-height track drawn behind a bar, marking the column the intake
/// fills. Gives every chart vertical structure aligned exactly to the bars,
/// which [FlGridData.drawVerticalLine] cannot do on a bar chart.
BackgroundBarChartRodData _rodTrack(BuildContext context, double maxY) {
  final ob = OnboardingTheme.of(context);
  return BackgroundBarChartRodData(
    show: true,
    toY: maxY,
    color: ob.textPrimary.withValues(alpha: 0.08),
  );
}

FlBorderData _bottomBorderOnly(BuildContext context) {
  final ob = OnboardingTheme.of(context);
  return FlBorderData(
    show: true,
    border: Border(
      bottom: BorderSide(
        color: ob.textPrimary.withValues(alpha: 0.2),
        width: 1,
      ),
    ),
  );
}

/// Dashed target line with its value printed at the right edge.
ExtraLinesData _goalLine(BuildContext context, double goal, String label) {
  final ob = OnboardingTheme.of(context);
  return ExtraLinesData(
    horizontalLines: [
      HorizontalLine(
        y: goal,
        color: _ChartStyle.goalLine.withValues(alpha: 0.7),
        strokeWidth: 1,
        dashArray: const [5, 4],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topRight,
          padding: const EdgeInsets.only(right: 2, bottom: 2),
          labelResolver: (_) => label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: ob.textPrimary.withValues(alpha: 0.8),
          ),
        ),
      ),
    ],
  );
}

/// Tap-to-reveal value tooltip. No labels are drawn on the bars by default;
/// tapping a bar pops its value in a small dark bubble so the numbers never
/// overlap adjacent bars.
BarTouchData _valueLabels(
  BuildContext context, {
  required String Function(double) format,
}) {
  return BarTouchData(
    enabled: true,
    touchTooltipData: BarTouchTooltipData(
      tooltipRoundedRadius: 6,
      tooltipPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      tooltipMargin: 4,
      getTooltipColor: (_) => Colors.black.withValues(alpha: 0.7),
      getTooltipItem: (group, groupIndex, rod, rodIndex) => rod.toY > 0
          ? BarTooltipItem(
              format(rod.toY),
              const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            )
          : null,
    ),
  );
}

// ─── Day: intake per hour ──────────────────────────────────────────────────────

/// "Theo giờ" — one bar per hour of the selected day, with stats footer.
class DayHourlyChart extends StatelessWidget {
  const DayHourlyChart({
    super.key,
    required this.hourlyTotals,
    required this.isOz,
    this.dailyGoal = 0,
  });

  /// Hour of day (0–23) -> ml.
  final Map<int, int> hourlyTotals;
  final bool isOz;
  final int dailyGoal;

  double _convert(int ml) =>
      isOz ? UnitConverter.mlToOz(ml.toDouble()) : ml.toDouble();

  String _hhmm(int hour) => '${hour.toString().padLeft(2, '0')}:00';

  /// Peak hour (highest value). Returns null if no data.
  int? get _peakHour {
    int? best;
    for (var h = 0; h < 24; h++) {
      final v = hourlyTotals[h] ?? 0;
      if (v > 0 && (best == null || v > (hourlyTotals[best] ?? 0))) best = h;
    }
    return best;
  }

  /// Lowest non-zero hour. Returns null if no data.
  int? get _lowestHour {
    int? worst;
    for (var h = 0; h < 24; h++) {
      final v = hourlyTotals[h] ?? 0;
      if (v > 0 && (worst == null || v < (hourlyTotals[worst] ?? 0))) worst = h;
    }
    return worst;
  }

  @override
  Widget build(BuildContext context) {
    var rawMax = 0.0;
    for (var h = 0; h < 24; h++) {
      final v = _convert(hourlyTotals[h] ?? 0);
      if (v > rawMax) rawMax = v;
    }
    final hoursWithData = hourlyTotals.values.where((v) => v > 0).length;
    // Y axis is scaled to the full daily goal so the goal line sits near the top
    // and every hour's bar reads against the real target — not a per-hour
    // fraction of it. Axis ceiling always lands above the goal.
    final goalY = _convert(dailyGoal);
    final reference = math.max(rawMax, dailyGoal > 0 ? goalY : 0.0);
    final maxY = _ChartStyle.niceMax(
      math.max(reference, isOz ? 8 : 100) * 1.05,
      divisions: 5,
    );
    final interval = maxY / 5;
    final leftAxis = _LeftAxis(
      maxY: maxY,
      interval: interval,
      context: context,
    );
    final showGoal = dailyGoal > 0;

    final groups = <BarChartGroupData>[
      for (var h = 0; h < 24; h++)
        BarChartGroupData(
          x: h,
          barRods: [
            BarChartRodData(
              toY: _convert(hourlyTotals[h] ?? 0),
              gradient: _ChartStyle.barGradient,
              width: 10,
              borderRadius: BorderRadius.zero,
              backDrawRodData: _rodTrack(context, maxY),
            ),
          ],
        ),
    ];

    // Total for average calculation (hoursWithData already computed above)
    final totalMl = hourlyTotals.values.fold(0, (s, v) => s + v);
    final avgPerHour = hoursWithData > 0 ? totalMl ~/ hoursWithData : 0;

    final peak = _peakHour;
    final lowest = _lowestHour;
    final peakLabel = peak != null
        ? '${_hhmm(peak)} – ${_hhmm((peak + 1) % 24)}'
        : '--';
    final lowestLabel = lowest != null
        ? '${_hhmm(lowest)} – ${_hhmm((lowest + 1) % 24)}'
        : '--';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AxisUnitLabel(unit: isOz ? 'oz' : 'ml'),
        const SizedBox(height: 8),
        SizedBox(
          height: 190,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              minY: 0,
              barGroups: groups,
              extraLinesData: showGoal
                  ? _goalLineTeal(goalY)
                  : ExtraLinesData(),
              gridData: _grid(context, interval),
              borderData: _bottomBorderOnly(context),
              barTouchData: _valueLabels(
                context,
                format: (v) => v > 0 ? v.round().toString() : '',
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: leftAxis.titles,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final h = value.toInt();
                      if (h % 4 != 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(left: 28, top: 5),
                        child: Text(
                          _hhmm(h),
                          style: TextStyle(fontSize: 10, color: Colors.white70),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            duration: Duration.zero,
          ),
        ),
        const SizedBox(height: 8),
        _HourlyStats(
          avgLabel:
              '${UnitConverter.formatVolumeValue(_convert(avgPerHour), isOz ? 'oz' : 'ml')} ${isOz ? 'oz' : 'ml'}/h',
          peakLabel: peakLabel,
          lowestLabel: lowestLabel,
        ),
      ],
    );
  }
}

/// Dashed target line with no printed value — the Day tab's treatment, shared
/// by every chart that follows it.
ExtraLinesData _goalLineTeal(double goal) {
  return ExtraLinesData(
    horizontalLines: [
      HorizontalLine(
        y: goal,
        color: _ChartStyle.goalLine.withValues(alpha: 0.7),
        strokeWidth: 1,
        dashArray: const [5, 4],
      ),
    ],
  );
}

class _HourlyStats extends StatelessWidget {
  const _HourlyStats({
    required this.avgLabel,
    required this.peakLabel,
    required this.lowestLabel,
  });

  final String avgLabel;
  final String peakLabel;
  final String lowestLabel;

  @override
  Widget build(BuildContext context) {
    return ChartStatsRow(
      stats: [
        ChartStat(
          icon: Icons.trending_down_rounded,
          iconColor: const Color(0xFFFF6B6B),
          label: 'lowest_hour'.tr,
          value: lowestLabel,
        ),
        ChartStat(
          icon: Icons.water_rounded,
          iconColor: AppColors.accentTeal,
          label: 'avg_per_hour'.tr,
          value: avgLabel,
        ),
        ChartStat(
          icon: Icons.trending_up_rounded,
          iconColor: AppColors.primary500Dark,
          label: 'peak_hour'.tr,
          value: peakLabel,
        ),
      ],
    );
  }
}

/// One cell of a [ChartStatsRow].
class ChartStat {
  const ChartStat({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
}

/// Footer strip under a history chart: evenly split cells separated by hairline
/// dividers. Defined by the Day tab and reused by the other tabs so the spacing,
/// icon size and type scale stay identical across them.
class ChartStatsRow extends StatelessWidget {
  const ChartStatsRow({super.key, required this.stats});

  final List<ChartStat> stats;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 36,
                color: ob.textPrimary.withValues(alpha: 0.12),
              ),
            Expanded(child: _StatChip(stat: stats[i])),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.stat});

  final ChartStat stat;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(stat.icon, size: 24, color: stat.iconColor),
        Text(
          stat.label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white60,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          stat.value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.primary500Dark,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─── Week: one bar per weekday ─────────────────────────────────────────────────

/// Seven bars (Mon–Sun) with the day's total printed above each.
class WeekBarChart extends StatelessWidget {
  const WeekBarChart({
    super.key,
    required this.dailyTotals,
    required this.dailyGoal,
    required this.isOz,
  });

  /// Seven entries, index 0 = Monday, in ml.
  final List<int> dailyTotals;
  final int dailyGoal;
  final bool isOz;

  @override
  Widget build(BuildContext context) {
    double convert(num ml) =>
        isOz ? UnitConverter.mlToOz(ml.toDouble()) : ml.toDouble();

    final values = dailyTotals.map(convert).toList();
    final goal = convert(dailyGoal);
    final dataMax = values.fold<double>(0, (m, v) => v > m ? v : m);
    // Five divisions and a non-zero floor, as on the Day tab, so an empty week
    // still draws a full gridline ladder instead of collapsing onto the axis.
    final axis = _Axis.fit(dataMax, goal, divisions: 5, floor: isOz ? 8 : 100);
    final maxY = axis.maxY;
    final interval = axis.interval;
    final leftAxis = _LeftAxis(
      maxY: maxY,
      interval: interval,
      context: context,
    );

    const labels = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AxisUnitLabel(unit: isOz ? 'oz' : 'ml'),
        const SizedBox(height: 8),
        SizedBox(
          height: 190,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              minY: 0,
              extraLinesData: axis.showGoal
                  ? _goalLineTeal(goal)
                  : ExtraLinesData(),
              barGroups: [
                for (var i = 0; i < values.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i],
                        gradient: _ChartStyle.barGradient,
                        width: 18,
                        borderRadius: BorderRadius.zero,
                        backDrawRodData: _rodTrack(context, maxY),
                      ),
                    ],
                  ),
              ],
              gridData: _grid(context, interval),
              borderData: _bottomBorderOnly(context),
              barTouchData: _valueLabels(
                context,
                format: (v) =>
                    isOz ? v.toStringAsFixed(0) : v.round().toString(),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: leftAxis.titles,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          labels[i].tr,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            duration: Duration.zero,
          ),
        ),
      ],
    );
  }
}

// ─── Month: daily trend line ───────────────────────────────────────────────────

/// Filled line across every day of the month, with the goal as a dashed line.
class MonthLineChart extends StatelessWidget {
  const MonthLineChart({
    super.key,
    required this.dailyTotals,
    required this.dailyGoal,
    required this.isOz,
  });

  /// One entry per day of the month, index 0 = the 1st, in ml.
  final List<int> dailyTotals;
  final int dailyGoal;
  final bool isOz;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);

    double convert(num ml) =>
        isOz ? UnitConverter.mlToOz(ml.toDouble()) : ml.toDouble();

    final goal = convert(dailyGoal);
    final spots = <FlSpot>[
      for (var i = 0; i < dailyTotals.length; i++)
        FlSpot((i + 1).toDouble(), convert(dailyTotals[i])),
    ];
    final dataMax = spots.fold<double>(0, (m, s) => s.y > m ? s.y : m);
    final axis = _Axis.fit(dataMax, goal, divisions: 3);
    final maxY = axis.maxY;
    final interval = axis.interval;
    final leftAxis = _LeftAxis(
      maxY: maxY,
      interval: interval,
      context: context,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AxisUnitLabel(unit: isOz ? 'oz' : 'ml'),
        const SizedBox(height: 6),
        SizedBox(
          height: 190,
          child: LineChart(
            LineChartData(
              minX: 1,
              maxX: dailyTotals.length.toDouble(),
              minY: 0,
              maxY: maxY,
              extraLinesData: axis.showGoal
                  ? _goalLine(
                      context,
                      goal,
                      UnitConverter.formatVolumeValue(
                        dailyGoal.toDouble(),
                        isOz ? 'oz' : 'ml',
                      ),
                    )
                  : ExtraLinesData(),
              // Matches the day labels below (1st, then every 5th).
              gridData: _grid(context, interval, verticalInterval: 5),
              borderData: _bottomBorderOnly(context),
              lineTouchData: const LineTouchData(enabled: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.25,
                  preventCurveOverShooting: true,
                  barWidth: 2,
                  gradient: const LinearGradient(
                    colors: [_ChartStyle.barTop, _ChartStyle.barTop],
                  ),
                  dotData: FlDotData(
                    show: dailyTotals.length <= 31,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                          radius: 2.5,
                          color: AppColors.basic500,
                          strokeWidth: 1.5,
                          strokeColor: _ChartStyle.barTop,
                        ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _ChartStyle.barTop.withValues(alpha: 0.45),
                        _ChartStyle.barBottom.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: leftAxis.titles,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final day = value.round();
                      final lastDay = dailyTotals.length;
                      // The 1st, every 5th day, and the last one — but drop
                      // the last label when it would collide with the 5th-day
                      // tick beside it (30 and 31 printed as "3031").
                      final isLast =
                          day == lastDay && lastDay - (lastDay ~/ 5) * 5 >= 3;
                      if (day != 1 && day % 5 != 0 && !isLast) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 10,
                            color: ob.textPrimary.withValues(alpha: 0.7),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            duration: Duration.zero,
          ),
        ),
      ],
    );
  }
}

// ─── Month: one bar per day ────────────────────────────────────────────────────

/// One bar per day of the month, with the daily goal as a dashed line.
class MonthBarChart extends StatelessWidget {
  const MonthBarChart({
    super.key,
    required this.dailyTotals,
    required this.dailyGoal,
    required this.isOz,
  });

  /// One entry per day of the month, index 0 = the 1st, in ml.
  final List<int> dailyTotals;
  final int dailyGoal;
  final bool isOz;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);

    double convert(num ml) =>
        isOz ? UnitConverter.mlToOz(ml.toDouble()) : ml.toDouble();

    final values = dailyTotals.map(convert).toList();
    final goal = convert(dailyGoal);
    final dataMax = values.fold<double>(0, (m, v) => v > m ? v : m);
    final axis = _Axis.fit(dataMax, goal, divisions: 4);
    final maxY = axis.maxY;
    final interval = axis.interval;
    final leftAxis = _LeftAxis(
      maxY: maxY,
      interval: interval,
      context: context,
    );
    final lastDay = dailyTotals.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AxisUnitLabel(unit: isOz ? 'oz' : 'ml'),
        const SizedBox(height: 6),
        SizedBox(
          height: 190,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceBetween,
              maxY: maxY,
              minY: 0,
              extraLinesData: axis.showGoal
                  ? _goalLine(
                      context,
                      goal,
                      UnitConverter.formatVolumeValue(
                        dailyGoal.toDouble(),
                        isOz ? 'oz' : 'ml',
                      ),
                    )
                  : ExtraLinesData(),
              barGroups: [
                for (var i = 0; i < values.length; i++)
                  BarChartGroupData(
                    x: i + 1,
                    barRods: [
                      BarChartRodData(
                        toY: values[i],
                        gradient: _ChartStyle.barGradient,
                        width: 6,
                        borderRadius: BorderRadius.zero,
                        backDrawRodData: _rodTrack(context, maxY),
                      ),
                    ],
                  ),
              ],
              gridData: _grid(context, interval),
              borderData: _bottomBorderOnly(context),
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: leftAxis.titles,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final day = value.round();
                      final isLast =
                          day == lastDay && lastDay - (lastDay ~/ 5) * 5 >= 3;
                      if (day != 1 && day % 5 != 0 && !isLast) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 10,
                            color: ob.textPrimary.withValues(alpha: 0.7),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            duration: Duration.zero,
          ),
        ),
      ],
    );
  }
}

// ─── Year: monthly goal-completion rate ─────────────────────────────────────────

/// Filled line of each month's goal-completion percentage, with the target
/// percentage drawn as a dashed line and each point's value printed above it.
class YearGoalRateChart extends StatelessWidget {
  const YearGoalRateChart({
    super.key,
    required this.monthlyRates,
    this.targetPct = 100,
  });

  /// Twelve entries, index 0 = January, in percent (may exceed 100).
  final List<double> monthlyRates;

  /// The dashed reference line, e.g. 100%.
  final double targetPct;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);

    final spots = <FlSpot>[
      for (var i = 0; i < monthlyRates.length; i++)
        FlSpot((i + 1).toDouble(), monthlyRates[i]),
    ];
    final dataMax = monthlyRates.fold<double>(0, (m, v) => v > m ? v : m);
    final maxY = _ChartStyle.niceMax(
      math.max(dataMax, targetPct) * 1.15,
      divisions: 4,
    );
    final interval = maxY / 4;
    final leftAxis = _LeftAxis(
      maxY: maxY,
      interval: interval,
      context: context,
    );

    final barData = LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.2,
      preventCurveOverShooting: true,
      barWidth: 2,
      color: _ChartStyle.barTop,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
          radius: 2,
          color: _ChartStyle.barTop,
          strokeWidth: 1,
          strokeColor: Colors.white,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _ChartStyle.barTop.withValues(alpha: 0.35),
            _ChartStyle.barBottom.withValues(alpha: 0.02),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AxisUnitLabel(unit: '%'),
        const SizedBox(height: 6),
        SizedBox(
          height: 190,
          child: LineChart(
            LineChartData(
              minX: 0.5,
              maxX: monthlyRates.length + 0.5,
              minY: 0,
              maxY: maxY,
              extraLinesData: _goalLine(
                context,
                targetPct,
                '${targetPct.round()}%',
              ),
              // One rule per month, matching the T1–T12 labels below.
              gridData: _grid(context, interval, verticalInterval: 1),
              borderData: _bottomBorderOnly(context),
              lineBarsData: [barData],
              showingTooltipIndicators: [
                for (var i = 0; i < spots.length; i++)
                  ShowingTooltipIndicators([LineBarSpot(barData, 0, spots[i])]),
              ],
              lineTouchData: LineTouchData(
                enabled: false,
                touchTooltipData: LineTouchTooltipData(
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: 4,
                  getTooltipColor: (_) => Colors.transparent,
                  getTooltipItems: (spots) => [
                    for (final s in spots)
                      LineTooltipItem(
                        '${s.y.round()}%',
                        TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: ob.textPrimary.withValues(alpha: 0.9),
                        ),
                      ),
                  ],
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: leftAxis.titles,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 1 || i > 12) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'T$i',
                          style: TextStyle(
                            fontSize: 9,
                            color: ob.textPrimary.withValues(alpha: 0.7),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            duration: Duration.zero,
          ),
        ),
      ],
    );
  }
}

// ─── Year: one bar per month ───────────────────────────────────────────────────

/// Twelve bars with compact value labels; months still to come are drawn as
/// empty outlines so the year reads as a plan, not a gap.
class YearBarChart extends StatelessWidget {
  const YearBarChart({
    super.key,
    required this.monthlyTotals,
    required this.monthlyGoals,
    required this.isFutureMonth,
    required this.goalLabel,
    required this.isOz,
  });

  /// Twelve entries, index 0 = January, in ml.
  final List<int> monthlyTotals;

  /// Twelve entries with each month's goal in ml — the dashed line is drawn at
  /// their average, since months differ in length.
  final List<int> monthlyGoals;

  final bool Function(int month) isFutureMonth;

  /// Text printed on the goal line (the whole year's target).
  final String goalLabel;

  final bool isOz;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);

    double convert(num ml) =>
        isOz ? UnitConverter.mlToOz(ml.toDouble()) : ml.toDouble();

    final values = monthlyTotals.map(convert).toList();
    final avgMonthlyGoal = convert(
      monthlyGoals.reduce((a, b) => a + b) / monthlyGoals.length,
    );
    final dataMax = values.fold<double>(0, (m, v) => v > m ? v : m);
    final axis = _Axis.fit(dataMax, avgMonthlyGoal, divisions: 3);
    final maxY = axis.maxY;
    final interval = axis.interval;
    final leftAxis = _LeftAxis(
      maxY: maxY,
      interval: interval,
      context: context,
      compact: true,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AxisUnitLabel(unit: isOz ? 'oz' : 'ml'),
        const SizedBox(height: 6),
        SizedBox(
          height: 190,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              minY: 0,
              extraLinesData: axis.showGoal
                  ? _goalLine(context, avgMonthlyGoal, goalLabel)
                  : ExtraLinesData(),
              barGroups: [
                for (var i = 0; i < values.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i],
                        gradient: _ChartStyle.barGradient,
                        width: 13,
                        borderRadius: BorderRadius.zero,
                        backDrawRodData: _rodTrack(context, maxY),
                      ),
                    ],
                  ),
              ],
              gridData: _grid(context, interval),
              borderData: _bottomBorderOnly(context),
              barTouchData: _valueLabels(
                context,
                format: UnitConverter.formatCompact,
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: leftAxis.titles,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i > 11) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'month_short'.trParams({'args1': '${i + 1}'}),
                          style: TextStyle(
                            fontSize: 9,
                            color: ob.textPrimary.withValues(alpha: 0.7),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            duration: Duration.zero,
          ),
        ),
      ],
    );
  }
}
