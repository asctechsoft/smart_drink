import 'dart:math' as math;
import 'package:dsp_base/app_material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waternudge/controller/languages_controller.dart';
import 'package:waternudge/controller/settings_controller.dart';
import 'package:waternudge/controller/user_profile_controller.dart';
import 'package:waternudge/presentation/common_components/circular_time_picker.dart';
import 'package:waternudge/presentation/common_components/gender_card.dart';
import 'package:waternudge/presentation/common_components/selectable_option_tile.dart';
import 'package:waternudge/presentation/common_components/primary_bottom_sheet.dart';
import 'package:waternudge/presentation/common_components/toggle_selector.dart';
import 'package:waternudge/presentation/common_components/wheel_picker.dart';
import 'package:waternudge/presentation/common_components/primary_button.dart';
import 'package:waternudge/presentation/screens_settings/components/language_list_widget.dart';
import 'package:waternudge/utils/unit_converter.dart';
import 'package:waternudge/values/app_colors.dart';
import 'package:waternudge/values/onboarding_theme.dart';
import 'package:get/get.dart';

// Helpers removed - using PrimaryBottomSheet instead

// ─── Gender Sheet ─────────────────────────────────────────────────────────────

void showGenderSheet(BuildContext context) {
  final ctrl = Get.find<UserProfileController>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _GenderSheet(
      initialGender: ctrl.profile.value.gender,
      onSave: (gender) {
        ctrl.updateGender(gender);
        Navigator.pop(ctx);
      },
    ),
  );
}

class _GenderSheet extends StatefulWidget {
  final String initialGender;
  final void Function(String) onSave;
  const _GenderSheet({required this.initialGender, required this.onSave});

  @override
  State<_GenderSheet> createState() => _GenderSheetState();
}

class _GenderSheetState extends State<_GenderSheet> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialGender;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A2556),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'select_your_gender'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'personalize_your_water_needs'.tr,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GenderCard(
                label: 'male',
                icon: 'assets/images/webp/img_men.webp',
                isSelected: _selected == 'male',
                onTap: () => setState(() => _selected = 'male'),
              ),
              const SizedBox(width: 16),
              GenderCard(
                label: 'female',
                icon: 'assets/images/webp/img_women.webp',
                isSelected: _selected == 'female',
                onTap: () => setState(() => _selected = 'female'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: PrimaryButton(
              width: double.infinity,
              text: 'save_changes'.tr,
              useGradient: true,
              onPressed: () => widget.onSave(_selected),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Weather Sheet ────────────────────────────────────────────────────────────

void showWeatherSheet(BuildContext context) {
  final ctrl = Get.find<UserProfileController>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _WeatherSheet(
      initialCondition: ctrl.profile.value.weatherCondition,
      onSave: (condition) {
        ctrl.updateWeatherCondition(condition);
        Navigator.pop(ctx);
      },
    ),
  );
}

class _WeatherSheet extends StatefulWidget {
  final String initialCondition;
  final void Function(String) onSave;
  const _WeatherSheet({required this.initialCondition, required this.onSave});

  @override
  State<_WeatherSheet> createState() => _WeatherSheetState();
}

class _WeatherSheetState extends State<_WeatherSheet> {
  late String _selected;

  static const _options = [
    ('hot', 'assets/images/svg/ic_wather_hot.svg'),
    ('normal', 'assets/images/svg/ic_wather_normal.svg'),
    ('cold', 'assets/images/svg/ic_wather_cold.svg'),
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialCondition;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A2556),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'weather'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'settings_weather_desc'.tr,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  const Text('🌍', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'weather_hint'.tr,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: _options.map((opt) {
                final (key, icon) = opt;
                final isSelected = _selected == key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SelectableOptionTile(
                    icon: icon,
                    label: key.tr,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selected = key),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: PrimaryButton(
              width: double.infinity,
              text: 'save_changes'.tr,
              useGradient: true,
              onPressed: () => widget.onSave(_selected),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Weight Sheet ─────────────────────────────────────────────────────────────

void showWeightSheet(BuildContext context) {
  final ctrl = Get.find<UserProfileController>();
  final settingsCtrl = Get.find<SettingsController>();
  final String initUnit = ctrl.profile.value.weightUnit == 'lb' ? 'lb' : 'kg';
  final int initKg = ctrl.profile.value.weight.round().clamp(20, 200);
  final int initLb = UnitConverter.kgToLb(
    ctrl.profile.value.weight,
  ).round().clamp(44, 441);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _WeightSheet(
      initialKg: initKg,
      initialLb: initLb,
      initialUnit: initUnit,
      onSave: (kg, lb, unit) {
        final saveKg = unit == 'lb'
            ? UnitConverter.lbToKg(lb.toDouble())
            : kg.toDouble();
        ctrl.updateWeight(saveKg, 'kg');
        settingsCtrl.setWeightUnit(unit);
        Navigator.pop(ctx);
      },
    ),
  );
}

class _WeightSheet extends StatefulWidget {
  final int initialKg;
  final int initialLb;
  final String initialUnit;
  final void Function(int kg, int lb, String unit) onSave;

  const _WeightSheet({
    required this.initialKg,
    required this.initialLb,
    required this.initialUnit,
    required this.onSave,
  });

  @override
  State<_WeightSheet> createState() => _WeightSheetState();
}

class _WeightSheetState extends State<_WeightSheet> {
  late int _kg;
  late int _lb;
  late String _unit;

  @override
  void initState() {
    super.initState();
    _kg = widget.initialKg;
    _lb = widget.initialLb;
    _unit = widget.initialUnit;
  }

  int get _displayValue => _unit == 'lb' ? _lb : _kg;
  int get _minVal => _unit == 'lb' ? 44 : 20;
  int get _maxVal => _unit == 'lb' ? 441 : 200;

  void _onRulerChanged(int v) {
    setState(() {
      if (_unit == 'lb') {
        _lb = v;
      } else {
        _kg = v;
      }
    });
  }

  void _switchUnit(String newUnit) {
    if (newUnit == _unit) return;
    setState(() {
      if (newUnit == 'lb') {
        _lb = UnitConverter.kgToLb(_kg.toDouble()).round().clamp(44, 441);
      } else {
        _kg = UnitConverter.lbToKg(_lb.toDouble()).round().clamp(20, 200);
      }
      _unit = newUnit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A2556),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Icon
          Center(
            child: Image.asset(
              'assets/images/webp/img_weight.webp',
              width: 68,
              height: 68,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 16),
          Text(
            'weight'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'settings_weight_desc'.tr,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 24),
          // Value display
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$_displayValue',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: '  $_unit',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Ruler
          _WeightRuler(
            value: _displayValue,
            min: _minVal,
            max: _maxVal,
            onChanged: _onRulerChanged,
          ),
          const SizedBox(height: 24),
          // Unit toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ToggleSelector(
              compact: true,
              options: const ['kg', 'lb'],
              selectedIndex: _unit == 'kg' ? 0 : 1,
              onChanged: (i) => _switchUnit(i == 0 ? 'kg' : 'lb'),
            ),
          ),
          const SizedBox(height: 24),
          // Save button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: PrimaryButton(
              width: double.infinity,
              text: 'save_changes'.tr,
              useGradient: true,
              onPressed: () => widget.onSave(_kg, _lb, _unit),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightRuler extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final void Function(int) onChanged;

  const _WeightRuler({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<_WeightRuler> createState() => _WeightRulerState();
}

class _WeightRulerState extends State<_WeightRuler> {
  static const _pxPerUnit = 10.0;
  double _dragAccum = 0.0;
  late int _lastValue;

  @override
  void initState() {
    super.initState();
    _lastValue = widget.value;
  }

  @override
  void didUpdateWidget(_WeightRuler old) {
    super.didUpdateWidget(old);
    if (old.min != widget.min || old.max != widget.max) {
      _lastValue = widget.value;
      _dragAccum = 0.0;
    }
  }

  void _onPanStart(DragStartDetails _) {
    _dragAccum = 0.0;
    _lastValue = widget.value;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    _dragAccum -= d.delta.dx;
    final delta = (_dragAccum / _pxPerUnit).round();
    final newVal = (_lastValue + delta).clamp(widget.min, widget.max);
    if (newVal != widget.value) widget.onChanged(newVal);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 72,
        child: CustomPaint(
          painter: _WeightRulerPainter(
            value: widget.value,
            min: widget.min,
            max: widget.max,
          ),
          size: Size(MediaQuery.of(context).size.width, 72),
        ),
      ),
    );
  }
}

class _WeightRulerPainter extends CustomPainter {
  final int value;
  final int min;
  final int max;
  static const _pxPerUnit = 10.0;

  _WeightRulerPainter({
    required this.value,
    required this.min,
    required this.max,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    const tickY = 32.0;

    // Indicator
    final dotPaint = Paint()
      ..color = const Color(0xFF50D1F0)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, tickY - 14), 6, dotPaint);
    canvas.drawLine(
      Offset(cx, tickY - 8),
      Offset(cx, tickY + 6),
      Paint()
        ..color = const Color(0xFF50D1F0)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    final range = 20;
    for (int i = value - range; i <= value + range; i++) {
      if (i < min || i > max) continue;
      final dx = cx + (i - value) * _pxPerUnit;
      if (dx < 0 || dx > size.width) continue;

      final isMajor = i % 10 == 0;
      final isMid = i % 5 == 0;
      final tickH = isMajor ? 20.0 : (isMid ? 14.0 : 8.0);
      final alpha =
          1.0 - ((dx - cx).abs() / (size.width / 2)).clamp(0.0, 1.0) * 0.7;

      canvas.drawLine(
        Offset(dx, tickY),
        Offset(dx, tickY + tickH),
        Paint()
          ..color = Colors.white.withValues(
            alpha: alpha * (isMajor ? 0.9 : 0.5),
          )
          ..strokeWidth = isMajor ? 2.0 : 1.0
          ..strokeCap = StrokeCap.round,
      );

      if (isMid) {
        final tp = TextPainter(
          text: TextSpan(
            text: '$i',
            style: TextStyle(
              color: i == value
                  ? const Color(0xFF50D1F0)
                  : Colors.white.withValues(alpha: alpha * 0.5),
              fontSize: i == value ? 13 : 11,
              fontWeight: i == value ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(dx - tp.width / 2, tickY + tickH + 4));
      }
    }
  }

  @override
  bool shouldRepaint(_WeightRulerPainter old) =>
      old.value != value || old.min != min;
}

// ─── Height Sheet ─────────────────────────────────────────────────────────────

void showHeightSheet(BuildContext context) {
  final ctrl = Get.find<UserProfileController>();
  final settingsCtrl = Get.find<SettingsController>();
  final String initUnit = ctrl.profile.value.heightUnit == 'm'
      ? 'cm'
      : ctrl.profile.value.heightUnit;
  final double initHeight = ctrl.profile.value.heightUnit == 'm'
      ? ctrl.profile.value.height * 100
      : ctrl.profile.value.height;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _HeightSheet(
      initialCm: initHeight.clamp(100, 250).round(),
      initialUnit: initUnit == 'ft' ? 'ft/in' : 'cm',
      onSave: (cm, unit) {
        final h = unit == 'ft/in' ? cm.toDouble() : cm.toDouble();
        ctrl.saveProfile(
          ctrl.profile.value.copyWith(height: h, heightUnit: 'cm'),
        );
        settingsCtrl.setHeightUnit('cm');
        Navigator.pop(ctx);
      },
    ),
  );
}

class _HeightSheet extends StatefulWidget {
  final int initialCm;
  final String initialUnit;
  final void Function(int cm, String unit) onSave;

  const _HeightSheet({
    required this.initialCm,
    required this.initialUnit,
    required this.onSave,
  });

  @override
  State<_HeightSheet> createState() => _HeightSheetState();
}

class _HeightSheetState extends State<_HeightSheet> {
  late int _cm;
  late String _unit;

  static const _minCm = 100;
  static const _maxCm = 250;

  @override
  void initState() {
    super.initState();
    _cm = widget.initialCm;
    _unit = widget.initialUnit;
  }

  String _displayValue() {
    if (_unit == 'ft/in') {
      final totalIn = (_cm * 0.393701);
      final ft = totalIn ~/ 12;
      final inches = (totalIn % 12).round();
      return "$ft'${inches.toString().padLeft(2, '0')}\"";
    }
    return '$_cm';
  }

  String _unitLabel() => _unit == 'ft/in' ? 'ft/in' : 'cm';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A2556),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Icon
          Center(
            child: Image.asset(
              'assets/images/webp/img_height.webp',
              width: 68,
              height: 68,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'height'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'settings_height_desc'.tr,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 24),
          // Value display
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: _displayValue(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: '  ${_unitLabel()}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Ruler
          _HeightRuler(
            value: _cm,
            min: _minCm,
            max: _maxCm,
            onChanged: (v) => setState(() => _cm = v),
          ),
          const SizedBox(height: 24),
          // Unit toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ToggleSelector(
              compact: true,
              options: const ['cm', 'ft/in'],
              selectedIndex: _unit == 'cm' ? 0 : 1,
              onChanged: (i) => setState(() => _unit = i == 0 ? 'cm' : 'ft/in'),
            ),
          ),
          const SizedBox(height: 24),
          // Save button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: PrimaryButton(
              width: double.infinity,
              text: 'save_changes'.tr,
              useGradient: true,
              onPressed: () => widget.onSave(_cm, _unit),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeightRuler extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final void Function(int) onChanged;

  const _HeightRuler({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<_HeightRuler> createState() => _HeightRulerState();
}

class _HeightRulerState extends State<_HeightRuler> {
  static const _pxPerUnit = 10.0;
  double _dragAccum = 0.0;
  late int _lastValue;

  @override
  void initState() {
    super.initState();
    _lastValue = widget.value;
  }

  void _onPanStart(DragStartDetails _) {
    _dragAccum = 0.0;
    _lastValue = widget.value;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    _dragAccum -= d.delta.dx;
    final delta = (_dragAccum / _pxPerUnit).round();
    final newVal = (_lastValue + delta).clamp(widget.min, widget.max);
    if (newVal != widget.value) widget.onChanged(newVal);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 72,
        child: CustomPaint(
          painter: _RulerPainter(
            value: widget.value,
            min: widget.min,
            max: widget.max,
          ),
          size: Size(MediaQuery.of(context).size.width, 72),
        ),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  final int value;
  final int min;
  final int max;
  static const _pxPerUnit = 10.0;

  _RulerPainter({required this.value, required this.min, required this.max});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    const tickY = 32.0;

    // Draw indicator pointer (dot + line)
    final dotPaint = Paint()
      ..color = const Color(0xFF50D1F0)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, tickY - 14), 6, dotPaint);
    canvas.drawLine(
      Offset(cx, tickY - 8),
      Offset(cx, tickY + 6),
      Paint()
        ..color = const Color(0xFF50D1F0)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Ticks
    final range = 20;
    for (int i = value - range; i <= value + range; i++) {
      if (i < min || i > max) continue;
      final dx = cx + (i - value) * _pxPerUnit;
      if (dx < 0 || dx > size.width) continue;

      final isMajor = i % 10 == 0;
      final isMid = i % 5 == 0;
      final tickH = isMajor ? 20.0 : (isMid ? 14.0 : 8.0);
      final alpha =
          1.0 - ((dx - cx).abs() / (size.width / 2)).clamp(0.0, 1.0) * 0.7;

      canvas.drawLine(
        Offset(dx, tickY),
        Offset(dx, tickY + tickH),
        Paint()
          ..color = Colors.white.withValues(
            alpha: alpha * (isMajor ? 0.9 : 0.5),
          )
          ..strokeWidth = isMajor ? 2.0 : 1.0
          ..strokeCap = StrokeCap.round,
      );

      if (isMid) {
        final tp = TextPainter(
          text: TextSpan(
            text: '$i',
            style: TextStyle(
              color: i == value
                  ? const Color(0xFF50D1F0)
                  : Colors.white.withValues(alpha: alpha * 0.5),
              fontSize: i == value ? 13 : 11,
              fontWeight: i == value ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(dx - tp.width / 2, tickY + tickH + 4));
      }
    }
  }

  @override
  bool shouldRepaint(_RulerPainter old) => old.value != value;
}

// ─── Age Sheet ────────────────────────────────────────────────────────────────

/* void showAgeSheet(BuildContext context) {
  final ctrl = Get.find<UserProfileController>();
  int age = ctrl.profile.value.age;
  PrimaryBottomSheet.show(
    context: context,
    title: 'age',
    buttonText: 'save',
    onButtonPressed: () {
      ctrl.updateAge(age);
      Navigator.pop(context);
    },
    content: WheelPicker(
      minValue: 10,
      maxValue: 100,
      initialValue: age,
      onChanged: (v) => age = v,
      textColor: Colors.white,
    ),
  );
} */

// ─── Daily Goal Sheet ─────────────────────────────────────────────────────────

void showDailyGoalSheet(BuildContext context) {
  final ctrl = Get.find<UserProfileController>();
  final settingsCtrl = Get.find<SettingsController>();
  final unit = ctrl.profile.value.volumeUnit;
  final goalMl = ctrl.profile.value.dailyGoalMl;
  int displayValue = unit == 'oz'
      ? UnitConverter.mlToOz(goalMl.toDouble()).round()
      : goalMl;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _DailyGoalSheet(
      initialValue: displayValue,
      unit: unit,
      onSave: (value, u) {
        final savedMl = u == 'oz'
            ? UnitConverter.ozToMl(value.toDouble()).round()
            : value;
        ctrl.saveProfile(
          ctrl.profile.value.copyWith(dailyGoalMl: savedMl, volumeUnit: u),
        );
        settingsCtrl.setVolumeUnit(u);
        Navigator.pop(ctx);
      },
    ),
  );
}

class _DailyGoalSheet extends StatefulWidget {
  final int initialValue;
  final String unit;
  final void Function(int value, String unit) onSave;
  const _DailyGoalSheet({
    required this.initialValue,
    required this.unit,
    required this.onSave,
  });

  @override
  State<_DailyGoalSheet> createState() => _DailyGoalSheetState();
}

class _DailyGoalSheetState extends State<_DailyGoalSheet> {
  late int _value;
  late String _unit;

  int get _step => _unit == 'ml' ? 50 : 1;
  int get _min => _unit == 'ml' ? 500 : 16;
  int get _max => _unit == 'ml' ? 5000 : 170;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue.clamp(
      widget.unit == 'ml' ? 500 : 16,
      widget.unit == 'ml' ? 8000 : 270,
    );
    _unit = widget.unit;
  }

  void _increment() =>
      setState(() => _value = (_value + _step).clamp(_min, _max));
  void _decrement() =>
      setState(() => _value = (_value - _step).clamp(_min, _max));

  String _formatValue(int v) {
    if (_unit == 'ml' && v >= 1000) {
      final parts = v.toString();
      if (parts.length == 4) return '${parts[0]}.${parts.substring(1)}';
      return v.toString();
    }
    return v.toString();
  }

  double get _progress => ((_value - _min) / (_max - _min)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A2556),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'daily_goal'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'settings_daily_goal_desc'.tr,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Ring + controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CircleButton(icon: Icons.remove, onTap: _decrement),
                const SizedBox(width: 24),
                _GoalRing(
                  value: _value,
                  min: _min,
                  max: _max,
                  step: _step,
                  onChanged: (v) => setState(() => _value = v),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/images/svg/img_cup.svg',
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _formatValue(_value),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: ' $_unit',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'goal_current'.tr,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                _CircleButton(icon: Icons.add, onTap: _increment),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Recommendation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'goal_recommendation'.tr,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.info_outline, color: Colors.white24, size: 14),
            ],
          ),
          const SizedBox(height: 20),
          // Info card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.btnCyanStart.withValues(
                                  alpha: 0.2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.water_drop,
                                color: Color(0xFF57DCC0),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'goal_benefit_title'.tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _Benefit('goal_benefit_health'.tr)),
                            Expanded(child: _Benefit('goal_benefit_energy'.tr)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(child: _Benefit('goal_benefit_skin'.tr)),
                            Expanded(child: _Benefit('goal_benefit_weight'.tr)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    'assets/images/svg/img_cup.svg',
                    height: 72,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Save button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Builder(
              builder: (ctx) {
                final canSave = _value > _min;
                return PrimaryButton(
                  width: double.infinity,
                  height: 50,
                  text: 'save'.tr,
                  useGradient: true,
                  enabled: canSave,
                  onPressed: () => widget.onSave(_value, _unit),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalRing extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final int step;
  final Widget child;
  final void Function(int) onChanged;

  const _GoalRing({
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.child,
    required this.onChanged,
  });

  @override
  State<_GoalRing> createState() => _GoalRingState();
}

class _GoalRingState extends State<_GoalRing> {
  static const _size = 180.0;
  static const _cx = _size / 2;
  static const _cy = _size / 2;

  double? _lastAngle;
  double _accumulator = 0.0;

  double _angleFrom(Offset local) {
    final dx = local.dx - _cx;
    final dy = local.dy - _cy;
    return math.atan2(dx, -dy);
  }

  void _onPanStart(DragStartDetails d) {
    _lastAngle = _angleFrom(d.localPosition);
    _accumulator = widget.value.toDouble();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_lastAngle == null) return;
    final curr = _angleFrom(d.localPosition);
    var delta = curr - _lastAngle!;
    if (delta > math.pi) delta -= 2 * math.pi;
    if (delta < -math.pi) delta += 2 * math.pi;
    _lastAngle = curr;

    final range = (widget.max - widget.min).toDouble();
    _accumulator += (delta / (2 * math.pi)) * range;
    _accumulator = _accumulator.clamp(
      widget.min.toDouble(),
      widget.max.toDouble(),
    );
    final snapped =
        ((_accumulator - widget.min) / widget.step).round() * widget.step +
        widget.min;
    if (snapped != widget.value) {
      widget.onChanged(snapped);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ((widget.value - widget.min) / (widget.max - widget.min))
        .clamp(0.0, 1.0);
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      child: SizedBox(
        width: _size,
        height: _size,
        child: CustomPaint(
          painter: _RingPainter(progress: progress),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;
    const strokeWidth = 12.0;
    const startAngle = -math.pi / 2;

    // Track
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc with gradient
    if (progress > 0.01) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradientPaint = Paint()
        ..shader = SweepGradient(
          colors: const [
            Color(0xFF50D1F0),
            Color(0xFF1E69FF),
            Color(0xFF50D1F0),
          ],
          stops: const [0.0, 0.5, 1.0],
          startAngle: startAngle,
          endAngle: startAngle + 2 * math.pi,
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        rect,
        startAngle,
        2 * math.pi * progress,
        false,
        gradientPaint,
      );
    }

    // Start marker — always visible at 12 o'clock (minimum position)
    final markerAngle = startAngle;
    final markerX = center.dx + radius * math.cos(markerAngle);
    final markerY = center.dy + radius * math.sin(markerAngle);
    final isAtMin = progress <= 0.01;
    final markerPaint = Paint()
      ..color = isAtMin
          ? const Color(0xFF50D1F0)
          : Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(markerX, markerY), isAtMin ? 7 : 5, markerPaint);

    // Tick line at minimum when at start
    if (isAtMin) {
      final tickInner =
          center +
          Offset(
            (radius - strokeWidth) * math.cos(markerAngle),
            (radius - strokeWidth) * math.sin(markerAngle),
          );
      final tickOuter =
          center +
          Offset(
            (radius + strokeWidth) * math.cos(markerAngle),
            (radius + strokeWidth) * math.sin(markerAngle),
          );
      canvas.drawLine(
        tickInner,
        tickOuter,
        Paint()
          ..color = const Color(0xFF50D1F0).withValues(alpha: 0.6)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final String text;
  const _Benefit(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_outline_rounded,
          color: Color(0xFF57DCC0),
          size: 14,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

// ─── Units Sheet ──────────────────────────────────────────────────────────────

void showUnitsSheet(BuildContext context) {
  final settingsCtrl = Get.find<SettingsController>();
  final profileCtrl = Get.find<UserProfileController>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _UnitsSheet(
      initialVolumeUnit: settingsCtrl.volumeUnit.value,
      initialWeightUnit: settingsCtrl.weightUnit.value,
      initialHeightUnit: profileCtrl.profile.value.heightUnit == 'm'
          ? 'cm'
          : profileCtrl.profile.value.heightUnit,
      profileHeight: profileCtrl.profile.value.height,
      profileWeight: profileCtrl.profile.value.weight,
      onSave: (volUnit, weightUnit, heightUnit) {
        settingsCtrl.setVolumeUnit(volUnit);
        settingsCtrl.setWeightUnit(weightUnit);
        settingsCtrl.setHeightUnit(heightUnit);
        final p = profileCtrl.profile.value;
        double newWeight = p.weight;
        if (p.weightUnit != weightUnit) {
          newWeight = weightUnit == 'lb'
              ? UnitConverter.kgToLb(p.weight)
              : UnitConverter.lbToKg(p.weight);
        }
        profileCtrl.saveProfile(
          p.copyWith(
            volumeUnit: volUnit,
            weight: newWeight,
            weightUnit: weightUnit,
            heightUnit: heightUnit,
          ),
        );
        Navigator.pop(ctx);
      },
    ),
  );
}

class _UnitsSheet extends StatefulWidget {
  final String initialVolumeUnit;
  final String initialWeightUnit;
  final String initialHeightUnit;
  final double profileHeight;
  final double profileWeight;
  final void Function(String vol, String weight, String height) onSave;

  const _UnitsSheet({
    required this.initialVolumeUnit,
    required this.initialWeightUnit,
    required this.initialHeightUnit,
    required this.profileHeight,
    required this.profileWeight,
    required this.onSave,
  });

  @override
  State<_UnitsSheet> createState() => _UnitsSheetState();
}

class _UnitsSheetState extends State<_UnitsSheet> {
  late String _volUnit;
  late String _weightUnit;
  late String _heightUnit;

  @override
  void initState() {
    super.initState();
    _volUnit = widget.initialVolumeUnit;
    _weightUnit = widget.initialWeightUnit;
    _heightUnit = widget.initialHeightUnit;
  }

  String _heightDisplay() {
    if (_heightUnit == 'ft/in') {
      final totalIn = widget.profileHeight * 0.393701;
      final ft = totalIn ~/ 12;
      final inches = (totalIn % 12).round();
      return "$ft'${inches.toString().padLeft(2, '0')}\"";
    }
    return '${widget.profileHeight.round()} cm';
  }

  String _weightDisplay() {
    if (_weightUnit == 'lb') {
      return '${UnitConverter.kgToLb(widget.profileWeight).round()} lb';
    }
    return '${widget.profileWeight.round()} kg';
  }

  String _volumeDisplay() {
    if (_volUnit == 'oz') {
      return '${UnitConverter.mlToOz(250).toStringAsFixed(0)} oz';
    }
    return '250 ml';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A2556),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Icon
          Center(
            child: Image.asset(
              'assets/images/webp/img_unit.webp',
              width: 68,
              height: 68,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'units'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'units_subtitle'.tr,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 24),
          // Unit rows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _UnitRow(
                  icon: Icons.straighten_rounded,
                  label: 'unit_height'.tr,
                  options: const ['cm', 'ft/in'],
                  selected: _heightUnit,
                  onChanged: (v) => setState(() => _heightUnit = v),
                ),
                const SizedBox(height: 12),
                _UnitRow(
                  icon: Icons.monitor_weight_outlined,
                  label: 'unit_weight'.tr,
                  options: const ['kg', 'lb'],
                  selected: _weightUnit,
                  onChanged: (v) => setState(() => _weightUnit = v),
                ),
                const SizedBox(height: 12),
                _UnitRow(
                  icon: Icons.water_drop_outlined,
                  label: 'unit_volume'.tr,
                  options: const ['ml', 'fl oz'],
                  selected: _volUnit,
                  onChanged: (v) =>
                      setState(() => _volUnit = v == 'fl oz' ? 'oz' : v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Preview card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'units_preview'.tr,
                    style: const TextStyle(
                      color: Color(0xFF57DCC0),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _PreviewItem(
                        icon: Icons.straighten_rounded,
                        label: 'height'.tr,
                        value: _heightDisplay(),
                      ),
                      _PreviewItem(
                        icon: Icons.monitor_weight_outlined,
                        label: 'weight'.tr,
                        value: _weightDisplay(),
                      ),
                      _PreviewItem(
                        icon: Icons.water_drop_outlined,
                        label: 'water'.tr,
                        value: _volumeDisplay(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Save button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: PrimaryButton(
              width: double.infinity,
              text: 'save_unit'.tr,
              useGradient: true,
              onPressed: () =>
                  widget.onSave(_volUnit, _weightUnit, _heightUnit),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> options;
  final String selected;
  final void Function(String) onChanged;

  const _UnitRow({
    required this.icon,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF57DCC0), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ToggleSelector(
          compact: true,
          options: options,
          selectedIndex: options.indexOf(
            options.firstWhere(
              (o) => o == selected || (o == 'fl oz' && selected == 'oz'),
              orElse: () => options.first,
            ),
          ),
          onChanged: (i) => onChanged(options[i]),
        ),
      ],
    );
  }
}

class _PreviewItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PreviewItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final parts = value.split(' ');
    final num = parts.first;
    final unit = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white54, size: 13),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: num,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Wakeup / Bedtime Sheets ─────────────────────────────────────────────────

void showWakeupSheet(BuildContext context) {
  final ctrl = Get.find<UserProfileController>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _TimeSheet(
      titleKey: 'what_time_do_you_wake_up',
      subtitleKey: 'helps_remind_you_to_drink_water',
      isNight: false,
      initialTime: ctrl.profile.value.wakeUpTime,
      onSave: (time) {
        ctrl.updateWakeUpTime(time);
        Navigator.pop(ctx);
      },
    ),
  );
}

void showBedtimeSheet(BuildContext context) {
  final ctrl = Get.find<UserProfileController>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _TimeSheet(
      titleKey: 'what_time_do_you_go_to_bed',
      subtitleKey: 'helps_remind_you_to_drink_water',
      isNight: true,
      initialTime: ctrl.profile.value.bedTime,
      onSave: (time) {
        ctrl.updateBedTime(time);
        Navigator.pop(ctx);
      },
    ),
  );
}

class _TimeSheet extends StatefulWidget {
  final String titleKey;
  final String subtitleKey;
  final bool isNight;
  final String initialTime;
  final void Function(String time) onSave;

  const _TimeSheet({
    required this.titleKey,
    required this.subtitleKey,
    required this.isNight,
    required this.initialTime,
    required this.onSave,
  });

  @override
  State<_TimeSheet> createState() => _TimeSheetState();
}

class _TimeSheetState extends State<_TimeSheet> {
  late String _time;

  @override
  void initState() {
    super.initState();
    _time = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A2556),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.titleKey.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            widget.subtitleKey.tr,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: CircularTimePicker(
              initialTime: _time,
              isNight: widget.isNight,
              onChanged: (t) => _time = t,
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: PrimaryButton(
              width: double.infinity,
              text: 'save_changes'.tr,
              useGradient: true,
              onPressed: () => widget.onSave(_time),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Language Sheet ───────────────────────────────────────────────────────────

void showLanguageSheet(BuildContext context) {
  if (!Get.isRegistered<LanguagesController>()) {
    Get.put(LanguagesController());
  }
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _LanguageSheet(),
  );
}

class _LanguageSheet extends StatefulWidget {
  const _LanguageSheet();

  @override
  State<_LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<_LanguageSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Rx<String> _query = ''.obs;
  late final LanguagesController _langCtrl;
  late Locale _initialLocale;
  late Worker _worker;

  @override
  void initState() {
    super.initState();
    _langCtrl = Get.find<LanguagesController>();
    _initialLocale = _langCtrl.currentAppLocale.value;
    _searchCtrl.addListener(() => _query.value = _searchCtrl.text.trim());
    _worker = ever(_langCtrl.currentAppLocale, (locale) {
      if (locale != _initialLocale && mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _worker.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Container(
      height: screenH * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF0A2556),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.btnCyanStart.withValues(alpha: 0.3),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                'assets/images/webp/img_language.webp',
                width: 44,
                height: 44,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'language'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'settings_language_desc'.tr,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchCtrl,
              cursorColor: Colors.white54,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'search'.tr,
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 15),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Colors.white38,
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() => LanguageListWidget(searchQuery: _query.value)),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

// ─── Time Format Sheet ────────────────────────────────────────────────────────

void showTimeFormatSheet(BuildContext context) {
  final ctrl = Get.find<SettingsController>();

  String getFormat(int index) {
    if (index == 1) return '12h';
    if (index == 2) return 'system';
    return '24h';
  }

  int getIndex(String format) {
    if (format == '12h') return 1;
    if (format == 'system') return 2;
    return 0;
  }

  String getLabel(int index) {
    if (index == 1) return 'time_12_hour'.tr;
    if (index == 2) return 'follow_the_system'.tr;
    return 'time_24_hour'.tr;
  }

  int displayValue = getIndex(ctrl.timeFormat.value);

  PrimaryBottomSheet.show(
    context: context,
    title: 'time_format',
    buttonText: 'save',
    onButtonPressed: () {
      ctrl.setTimeFormat(getFormat(displayValue));
      Navigator.pop(context);
    },
    content: StatefulBuilder(
      builder: (ctx, setState) => WheelPicker(
        minValue: 0,
        maxValue: 2,
        initialValue: displayValue,
        onChanged: (v) => displayValue = v,
        labelBuilder: getLabel,
        showIndicator: false,
        textColor: Colors.white,
        itemWidth: 250,
        isLooping: true,
        visibleItemCount: 3,
      ),
    ),
  );
}
