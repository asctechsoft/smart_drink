import 'dart:math' as math;

import 'package:dsp_base/app_material.dart';
import 'package:get/get.dart';
import 'package:waternudge/controller/settings_controller.dart';
import 'package:waternudge/utils/unit_converter.dart';
import 'package:waternudge/values/app_colors.dart';

const double _ringStroke = 3;
const double _arcStroke = 4.5;

/// Gap between the ring and the clock ticks drawn inside it.
const double _tickInset = 9;
const double _minorTickLength = 6;
const double _majorTickLength = 13;

/// One tick every 30 minutes, with longer ticks at 00/06/12/18.
const int _tickCount = 48;

const Color _accent = Color(0xFF7FE4FF);

/// A 24-hour dial: one full revolution covers a whole day, starting at the top.
/// Drag anywhere inside the dial to move the handle.
class CircularTimePicker extends StatefulWidget {
  final String initialTime;
  final ValueChanged<String> onChanged;

  /// Night dials show a moon in the middle, day dials a sun.
  final bool isNight;
  final double size;

  const CircularTimePicker({
    super.key,
    required this.initialTime,
    required this.onChanged,
    required this.isNight,
    this.size = 270,
  });

  @override
  State<CircularTimePicker> createState() => _CircularTimePickerState();
}

class _CircularTimePickerState extends State<CircularTimePicker> {
  static const int _minutesPerDay = 24 * 60;
  static const int _snapMinutes = 5;

  late int _minutes;

  @override
  void initState() {
    super.initState();
    _minutes = _parseMinutes(widget.initialTime);
  }

  static int _parseMinutes(String time) {
    final parts = time.split(':');
    final hour = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 7) : 7;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return (hour * 60 + minute) % _minutesPerDay;
  }

  String get _timeString {
    final h = _minutes ~/ 60;
    final m = _minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  void _updateFromOffset(Offset localPosition) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final vector = localPosition - center;
    if (vector.distance < 12) return;

    // atan2 measured from the top, growing clockwise.
    var angle = math.atan2(vector.dx, -vector.dy);
    if (angle < 0) angle += 2 * math.pi;

    final raw = angle / (2 * math.pi) * _minutesPerDay;
    final snapped =
        ((raw / _snapMinutes).round() * _snapMinutes) % _minutesPerDay;
    if (snapped == _minutes) return;

    setState(() => _minutes = snapped);
    widget.onChanged(_timeString);
  }

  /// Radius at which the hour labels sit, just inside the tick ring.
  double get _labelRadius =>
      widget.size / 2 - _ringStroke - _tickInset - _majorTickLength - 12;

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();

    return GestureDetector(
      onPanDown: (d) => _updateFromOffset(d.localPosition),
      onPanUpdate: (d) => _updateFromOffset(d.localPosition),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(widget.size),
              painter: _DialPainter(
                progress: _minutes / _minutesPerDay,
                isNight: widget.isNight,
              ),
            ),
            ..._buildHourLabels(),
            AppColumn(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSpacerH12,
                Obx(
                  () => AppText(
                    UnitConverter.formatTime(
                      _timeString,
                      settingsCtrl.timeFormat.value,
                    ),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: AppColors.basic500,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHourLabels() {
    const labels = {0: '00', 6: '06', 12: '12', 18: '18'};
    final radius = _labelRadius;
    return labels.entries.map((entry) {
      final angle = entry.key / 24 * 2 * math.pi;
      final dx = math.sin(angle) * radius;
      final dy = -math.cos(angle) * radius;
      return Positioned(
        left: widget.size / 2 + dx - 16,
        top: widget.size / 2 + dy - 9,
        child: SizedBox(
          width: 32,
          child: AppText(
            entry.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.basic500.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _DialPainter extends CustomPainter {
  final double progress;
  final bool isNight;

  _DialPainter({required this.progress, required this.isNight});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringRadius = size.width / 2 - _ringStroke / 2;

    _paintFace(canvas, center, ringRadius);
    _paintTicks(canvas, center, ringRadius);
    _paintRing(canvas, center, ringRadius);
    _paintProgress(canvas, center, ringRadius);
    _paintCenterIcon(canvas, center, size);
  }

  /// A slightly darker disc so the dial reads as a face on the gradient.
  void _paintFace(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.neutral500.withValues(alpha: 0.18),
            AppColors.neutral500.withValues(alpha: 0.42),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _paintTicks(Canvas canvas, Offset center, double ringRadius) {
    final outer = ringRadius - _ringStroke / 2 - _tickInset;
    for (var i = 0; i < _tickCount; i++) {
      final isMajor = i % (_tickCount ~/ 4) == 0;
      final angle = i / _tickCount * 2 * math.pi - math.pi / 2;
      final length = isMajor ? _majorTickLength : _minorTickLength;
      final inner = outer - length;
      final cos = math.cos(angle);
      final sin = math.sin(angle);
      canvas.drawLine(
        center + Offset(cos * outer, sin * outer),
        center + Offset(cos * inner, sin * inner),
        Paint()
          ..strokeWidth = isMajor ? 2.5 : 1.4
          ..strokeCap = StrokeCap.round
          ..color = AppColors.basic500.withValues(alpha: isMajor ? 0.8 : 0.34),
      );
    }
  }

  void _paintRing(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _ringStroke
        ..color = _accent.withValues(alpha: 0.45),
    );
  }

  void _paintProgress(Canvas canvas, Offset center, double radius) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;
    final sweep = progress * 2 * math.pi;

    if (sweep > 0) {
      canvas.drawArc(
        rect,
        startAngle,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _arcStroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
          ..color = _accent.withValues(alpha: 0.6),
      );
      canvas.drawArc(
        rect,
        startAngle,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _arcStroke
          ..strokeCap = StrokeCap.round
          ..shader = SweepGradient(
            transform: const GradientRotation(startAngle),
            colors: [_accent.withValues(alpha: 0.55), AppColors.basic500],
            stops: [0, progress.clamp(0.001, 1)],
          ).createShader(rect),
      );
    }

    final handle =
        center + Offset(math.sin(sweep) * radius, -math.cos(sweep) * radius);
    canvas.drawCircle(
      handle,
      14,
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
        ..color = _accent.withValues(alpha: 0.95),
    );
    canvas.drawCircle(handle, 9, Paint()..color = AppColors.basic500);
    canvas.drawCircle(handle, 6, Paint()..color = _accent);
  }

  /// Sun for daytime, crescent moon for night — drawn so both share the dial's
  /// glow treatment.
  void _paintCenterIcon(Canvas canvas, Offset center, Size size) {
    final iconCenter = Offset(center.dx, center.dy - size.height * 0.16);
    const coreRadius = 11.0;

    canvas.drawCircle(
      iconCenter,
      coreRadius + 6,
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
        ..color = _accent.withValues(alpha: 0.55),
    );

    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [AppColors.basic500, _accent],
      ).createShader(Rect.fromCircle(center: iconCenter, radius: coreRadius));

    if (isNight) {
      // Crescent: punch an offset circle out of the core.
      final path = Path.combine(
        PathOperation.difference,
        Path()..addOval(Rect.fromCircle(center: iconCenter, radius: coreRadius)),
        Path()..addOval(
          Rect.fromCircle(
            center: iconCenter.translate(coreRadius * 0.55, -coreRadius * 0.35),
            radius: coreRadius * 0.92,
          ),
        ),
      );
      canvas.drawPath(path, corePaint);
      return;
    }

    canvas.drawCircle(iconCenter, coreRadius, corePaint);
    const rayCount = 8;
    for (var i = 0; i < rayCount; i++) {
      final angle = i / rayCount * 2 * math.pi;
      final cos = math.cos(angle);
      final sin = math.sin(angle);
      canvas.drawLine(
        iconCenter + Offset(cos * (coreRadius + 4), sin * (coreRadius + 4)),
        iconCenter + Offset(cos * (coreRadius + 9), sin * (coreRadius + 9)),
        Paint()
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..color = _accent,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isNight != isNight;
}
