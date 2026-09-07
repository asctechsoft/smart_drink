import 'package:dsp_base/app_material.dart';
import 'package:waternudge/controller/onboarding_controller.dart';
import 'package:waternudge/presentation/common_components/primary_button.dart';
import 'package:waternudge/presentation/common_components/primary_bottom_sheet.dart';
import 'package:waternudge/values/onboarding_theme.dart';
import 'package:waternudge/utils/toast_utils.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class IntervalPickerSheet extends StatefulWidget {
  final OnboardingController controller;

  const IntervalPickerSheet({super.key, required this.controller});

  static void show(BuildContext context, OnboardingController controller) {
    PrimaryBottomSheet.show(
      context: context,
      title: 'interval'.tr,
      showSubmitButton: false,
      content: IntervalPickerSheet(controller: controller),
    );
  }

  @override
  State<IntervalPickerSheet> createState() => _IntervalPickerSheetState();
}

class _IntervalPickerSheetState extends State<IntervalPickerSheet> {
  late int hours;
  late int minutes;
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;

  @override
  void initState() {
    super.initState();
    hours = widget.controller.intervalMinutes.value ~/ 60;
    minutes = widget.controller.intervalMinutes.value % 60;
    hourController = FixedExtentScrollController(initialItem: hours);
    minuteController = FixedExtentScrollController(initialItem: minutes);
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  static const double _colWidth = 150;
  static const double _slotHeight = 56;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);

    return AppColumn(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          'interval_picker_hint'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: ob.textSubtitle,
          ),
        ),
        const AppSpacerH(20),
        AppRow(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _labeledColumn(ob, 'picker_hour', _hourWheel(ob)),
            // header (~20) + gap (6) + half wheel - half glyph, to sit the ":"
            // on the centre band.
            Padding(
              padding: const EdgeInsets.only(top: 116),
              child: AppText(
                ':',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ob.textPrimary,
                ),
              ),
            ),
            _labeledColumn(ob, 'picker_minute', _minuteWheel(ob)),
          ],
        ),
        const AppSpacerH(8),
        _preview(ob),
        const AppSpacerH(20),
        _infoPill(ob),
        const AppSpacerH(24),
        PrimaryButton(
          text: 'save'.tr,
          width: double.infinity,
          useGradient: true,
          onPressed: () {
            if (hours == 0 && minutes < 5) {
              ToastUtils.showToast(context, 'interval_min_5'.tr);
              return;
            }
            widget.controller.intervalMinutes.value = hours * 60 + minutes;
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _labeledColumn(OnboardingTheme ob, String headerKey, Widget wheel) {
    return AppColumn(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _colWidth,
          child: Center(
            child: AppText(
              headerKey.tr,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ob.textAccent,
              ),
            ),
          ),
        ),
        const AppSpacerH(6),
        _glowSlot(wheel),
      ],
    );
  }

  /// The wheel with a glowing selection box centred behind it.
  Widget _glowSlot(Widget wheel) {
    return SizedBox(
      width: _colWidth,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(
            child: Builder(
              builder: (context) {
                final ob = OnboardingTheme.of(context);
                return Container(
                  width: _colWidth,
                  height: _slotHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ob.textAccent, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: ob.textAccent.withValues(alpha: 0.5),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          wheel,
        ],
      ),
    );
  }

  Widget _hourWheel(OnboardingTheme ob) {
    return SizedBox(
      width: _colWidth,
      height: 200,
      child: ListWheelScrollView.useDelegate(
        controller: hourController,
        itemExtent: _slotHeight,
        physics: const FixedExtentScrollPhysics(),
        overAndUnderCenterOpacity: 1.0,
        onSelectedItemChanged: (i) => setState(() => hours = i),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            if (index < 0 || index > 12) return null;
            return _wheelItem(
              ob,
              '$index ${index <= 1 ? 'hour'.tr : 'hours'.tr}',
              (index - hours).abs(),
            );
          },
          childCount: 13,
        ),
      ),
    );
  }

  Widget _minuteWheel(OnboardingTheme ob) {
    return SizedBox(
      width: _colWidth,
      height: 200,
      child: ListWheelScrollView.useDelegate(
        controller: minuteController,
        itemExtent: _slotHeight,
        physics: const FixedExtentScrollPhysics(),
        overAndUnderCenterOpacity: 1.0,
        onSelectedItemChanged: (i) {
          int normalized = i % 60;
          if (normalized < 0) normalized += 60;
          setState(() => minutes = normalized);
        },
        childDelegate: ListWheelChildLoopingListDelegate(
          children: List.generate(60, (index) {
            int distance = (index - minutes).abs();
            if (distance > 30) distance = 60 - distance;
            return _wheelItem(
              ob,
              '${index.toString().padLeft(2, '0')} ${'min'.tr}',
              distance,
            );
          }),
        ),
      ),
    );
  }

  Widget _wheelItem(OnboardingTheme ob, String label, int distance) {
    final isSelected = distance == 0;
    Color itemColor = ob.textPrimary;
    if (distance == 1) {
      itemColor = ob.textPrimary.withValues(alpha: 0.5);
    } else if (distance >= 2) {
      itemColor = ob.textPrimary.withValues(alpha: 0.1);
    }
    return Center(
      child: AppText(
        label,
        style: TextStyle(
          fontSize: isSelected ? 20 : 13,
          fontWeight: FontWeight.w600,
          color: itemColor,
        ),
      ),
    );
  }

  Widget _preview(OnboardingTheme ob) {
    final text =
        '$hours ${hours <= 1 ? 'hour'.tr : 'hours'.tr} '
        '$minutes ${'min'.tr}';
    return ShaderMask(
      shaderCallback: (bounds) =>
          LinearGradient(colors: [ob.buttonStart, ob.buttonEnd]).createShader(bounds),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _infoPill(OnboardingTheme ob) {
    final every =
        '$hours ${hours <= 1 ? 'hour'.tr : 'hours'.tr} '
        '$minutes ${'min'.tr}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ob.textAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ob.textAccent.withValues(alpha: 0.3)),
      ),
      child: AppRow(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 20, color: ob.textAccent),
          const AppSpacerW(10),
          Flexible(
            child: AppText(
              'interval_pill_info'.trParams({'args1': every}),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ob.textPrimary.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

