import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/history_controller.dart';
import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/utils/unit_converter.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

class HistoryBarChart extends StatefulWidget {
  const HistoryBarChart({super.key});

  @override
  State<HistoryBarChart> createState() => _HistoryBarChartState();
}

class _HistoryBarChartState extends State<HistoryBarChart> {
  final ScrollController _scrollController = ScrollController();

  void _handleAutoScroll(
    HistoryController ctrl,
    double chartWidth,
    BoxConstraints constraints,
  ) {
    final viewMode = ctrl.viewMode.value;
    if (viewMode != HistoryViewMode.day && viewMode != HistoryViewMode.month) {
      return;
    }

    // Check if looking at today/current month
    final sel = ctrl.selectedDate.value;
    final now = DateTime.now();

    bool shouldScroll = false;
    double scrollTarget = 0;

    if (viewMode == HistoryViewMode.day) {
      final isToday =
          sel.year == now.year && sel.month == now.month && sel.day == now.day;
      if (isToday) {
        shouldScroll = true;
        scrollTarget = (now.hour / 24) * chartWidth;
      }
    } else if (viewMode == HistoryViewMode.month) {
      final isCurrentMonth = sel.year == now.year && sel.month == now.month;
      if (isCurrentMonth) {
        shouldScroll = true;
        final daysInMonth = DateTime(sel.year, sel.month + 1, 0).day;
        // Days are 1-indexed in Month view
        scrollTarget = ((now.day - 0.5) / daysInMonth) * chartWidth;
      }
    }

    if (!shouldScroll) return;

    // Use a post-frame callback to ensure layout is done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      final viewableWidth = constraints.maxWidth - 35;

      // Center the target point on screen if possible
      final offset = scrollTarget - (viewableWidth / 2);

      final clampedOffset = offset.clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );

      if (clampedOffset > 0) {
        _scrollController.animateTo(
          clampedOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();
    final settings = Get.find<SettingsController>();
    return Obx(() {
      final isOz = settings.volumeUnit.value == 'oz';
      final barGroups = _buildBarGroups(controller, isOz);
      final maxY = _computeMaxY(barGroups, isOz);
      final interval = _getYInterval(maxY, isOz);
      final viewMode = controller.viewMode.value;

      return LayoutBuilder(
        builder: (context, constraints) {
          final ob = OnboardingTheme.of(context);
          double chartWidth = constraints.maxWidth - 35;
          if (viewMode == HistoryViewMode.day) {
            chartWidth = 1200; // 24 cột * 50px
          } else if (viewMode == HistoryViewMode.month) {
            chartWidth = 800;
          }

          if (chartWidth < constraints.maxWidth - 35) {
            chartWidth = constraints.maxWidth - 35;
          }

          // Trigger auto-scroll if needed
          _handleAutoScroll(controller, chartWidth, constraints);

          return Row(
            children: [
              SizedBox(
                width: 30,
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    minY: 0,
                    titlesData: FlTitlesData(
                      show: true,
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: interval,
                          getTitlesWidget: (value, meta) =>
                              _leftTitlesWidget(value, meta, isOz),
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize:
                              18, // Phải trùng với bottom của chart chính để căn hàng
                          getTitlesWidget: (value, meta) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [],
                  ),
                  swapAnimationDuration: Duration.zero,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: chartWidth,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxY,
                        minY: 0,
                        barGroups: barGroups,
                        titlesData: FlTitlesData(
                          show: true,
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 18,
                              getTitlesWidget: (value, meta) =>
                                  _bottomTitle(value, controller),
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(
                              color: ob.borderReminderPill,
                              width: 1,
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: interval,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: ob.borderTab,
                            strokeWidth: 0.5,
                            dashArray: [4, 4],
                          ),
                        ),
                        barTouchData: BarTouchData(
                          enabled: false,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipPadding: EdgeInsets.zero,
                            tooltipMargin: 2,
                            getTooltipColor: (_) => Colors.transparent,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                isOz
                                    ? rod.toY
                                          .toStringAsFixed(1)
                                          .replaceAll(RegExp(r'\.0$'), '')
                                    : rod.toY.toInt().toString(),
                                TextStyle(
                                  color: ob.textSecondary,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 8,
                                  letterSpacing: 0.5,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      swapAnimationDuration: Duration.zero,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  Widget _leftTitlesWidget(double value, TitleMeta meta, bool isOz) {
    final ob = OnboardingTheme.of(context);
    if (value == meta.max) {
      return AppText(
        modifier: Modifier.padding(bottom: 20).paddingLR(right: 4),
        isOz ? '(oz)' : '(ml)',
        textAlign: TextAlign.right,
        style: TextStyle(fontSize: 10, color: ob.textSecondary),
      );
    }
    return AppText(
      modifier: Modifier.paddingLR(right: 4),
      value.toInt().toString(),
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: 9,
        color: ob.textPrimary,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  double _getYInterval(double maxY, bool isOz) {
    if (isOz) {
      if (maxY <= 50) return 2;
      if (maxY <= 100) return 20;
      if (maxY <= 200) return 50;
      if (maxY <= 500) return 100;
      return 200;
    }
    if (maxY <= 200) return 10;
    if (maxY <= 500) return 30;
    if (maxY <= 1200) return 160;
    if (maxY <= 3000) return 500;
    if (maxY <= 6000) return 1000;
    if (maxY <= 12000) return 2000;
    return 5000;
  }

  List<BarChartGroupData> _buildBarGroups(
    HistoryController controller,
    bool isOz,
  ) {
    switch (controller.viewMode.value) {
      case HistoryViewMode.day:
        final hourlyData = <int, double>{};
        for (final record in controller.dayRecords) {
          final hour = record.timestamp.hour;
          double amt = record.amountMl.toDouble();
          if (isOz) amt = UnitConverter.mlToOz(amt);
          hourlyData[hour] = (hourlyData[hour] ?? 0) + amt;
        }
        return List.generate(24, (i) {
          return _barGroup(i, hourlyData[i] ?? 0.0, controller.viewMode.value);
        });

      case HistoryViewMode.week:
        final weekData = <int, double>{};
        for (final s in controller.summaries) {
          final dt = DateTime.tryParse(s.dateKey);
          if (dt != null) {
            final day = dt.weekday - 1; // 0=Mon, 6=Sun
            double amt = s.totalMl.toDouble();
            if (isOz) amt = UnitConverter.mlToOz(amt);
            weekData[day] = (weekData[day] ?? 0) + amt;
          }
        }
        return List.generate(7, (i) {
          return _barGroup(i, weekData[i] ?? 0.0, controller.viewMode.value);
        });

      case HistoryViewMode.month:
        final dt = controller.selectedDate.value;
        final daysInMonth = DateTime(dt.year, dt.month + 1, 0).day;
        final dailyData = <int, double>{};
        for (final s in controller.summaries) {
          final parsed = DateTime.tryParse(s.dateKey);
          if (parsed != null) {
            double amt = s.totalMl.toDouble();
            if (isOz) amt = UnitConverter.mlToOz(amt);
            dailyData[parsed.day] = amt;
          }
        }
        return List.generate(daysInMonth, (i) {
          final day = i + 1;
          return _barGroup(
            day,
            dailyData[day] ?? 0.0,
            controller.viewMode.value,
          );
        });
    }
  }

  BarChartGroupData _barGroup(int x, double y, HistoryViewMode mode) {
    final ob = OnboardingTheme.of(context);
    return BarChartGroupData(
      x: x,
      showingTooltipIndicators: y > 0 ? [0] : [],
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: ob.gradientChart,
          width: _barWidth(mode),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(100)),
        ),
      ],
    );
  }

  double _barWidth(HistoryViewMode mode) {
    if (mode == HistoryViewMode.month) return 10;
    if (mode == HistoryViewMode.day)
      return 10; // Nhỏ lại cho thoáng (từ 12 -> 6)
    return 12; // Giữ nguyên cho tuần
  }

  double _computeMaxY(List<BarChartGroupData> barGroups, bool isOz) {
    double maxVal = isOz ? 10 : 200;
    for (final group in barGroups) {
      for (final rod in group.barRods) {
        if (rod.toY > maxVal) maxVal = rod.toY;
      }
    }
    return maxVal * 1.2;
  }

  Widget _bottomTitle(double value, HistoryController controller) {
    final ob = OnboardingTheme.of(context);
    String text;
    final is12h = Get.find<SettingsController>().timeFormat.value == '12h';
    switch (controller.viewMode.value) {
      case HistoryViewMode.day:
        final v = value.toInt();
        if (is12h) {
          final period = v < 12 ? 'am'.tr : 'pm'.tr;
          final hour12 = v > 12 ? v - 12 : v;
          text = '${hour12.toString().padLeft(2, '0')} $period';
        } else {
          text = '${v.toString().padLeft(2, '0')}:00';
        }
      case HistoryViewMode.week:
        const days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
        text = value.toInt() < days.length ? days[value.toInt()].tr : '';
      case HistoryViewMode.month:
        final day = value.toInt();
        text = day.toString().padLeft(2, '0');
    }
    return AppText(
      modifier: Modifier.padding(top: 4),
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: ob.textPrimary,
      ),
    );
  }
}

